using CampingNeretva.Service.Database;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using EasyNetQ;
using System;
using System.Threading;
using System.Threading.Tasks;
using EasyNetQ.DI;
using EasyNetQ.Serialization.NewtonsoftJson;
using CampingNeretva.Model.Models;

namespace CampingNeretva.Service.NotificationService
{
    public class ReservationNotificationSubscriber : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<ReservationNotificationSubscriber> _logger;

        public ReservationNotificationSubscriber(IServiceScopeFactory scopeFactory, ILogger<ReservationNotificationSubscriber> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            const int maxRetries = 5;
            const int retryDelayMs = 5000;

            while (!stoppingToken.IsCancellationRequested)
            {
                int retryCount = 0;
                bool connected = false;

                while (!connected && retryCount < maxRetries && !stoppingToken.IsCancellationRequested)
                {
                    try
                    {
                        _logger.LogInformation($"Attempting to connect to RabbitMQ (Attempt {retryCount + 1}/{maxRetries})");
                        using var bus = RabbitHutch.CreateBus("host=rabbitmq;username=guest;password=guest;timeout=60", x =>
                            x.Register<ISerializer>(_ => new NewtonsoftJsonSerializer()));
                        _logger.LogInformation("Connected to RabbitMQ, subscribing to email_service queue");

                        await bus.PubSub.SubscribeAsync<ReservationModel>("email_service", async reservation =>
                        {
                            try
                            {
                                using var scope = _scopeFactory.CreateScope();
                                var db = scope.ServiceProvider.GetRequiredService<_200012Context>();
                                var emailService = scope.ServiceProvider.GetRequiredService<EmailService>();

                                var user = await db.Users.FindAsync(reservation.UserId);
                                if (user != null)
                                {
                                    await emailService.SendReservationConfirmation(user.Email, user.FirstName, reservation);
                                    _logger.LogInformation($"✅ Email sent to {user.Email} for reservation #{reservation.ReservationId}");
                                }
                                else
                                {
                                    _logger.LogWarning($"❌ User not found for reservation #{reservation.ReservationId}");
                                }
                            }
                            catch (Exception ex)
                            {
                                _logger.LogError(ex, $"Failed to process reservation #{reservation.ReservationId}");
                            }
                        }, cancellationToken: stoppingToken);

                        _logger.LogInformation("Subscription to email_service queue established");
                        connected = true;
                        await Task.Delay(Timeout.Infinite, stoppingToken);
                    }
                    catch (Exception ex)
                    {
                        retryCount++;
                        _logger.LogError(ex, $"Failed to connect to RabbitMQ (Attempt {retryCount}/{maxRetries})");
                        if (retryCount >= maxRetries)
                        {
                            _logger.LogError("Max retries reached. Giving up on RabbitMQ connection.");
                            break;
                        }
                        await Task.Delay(retryDelayMs, stoppingToken);
                    }
                }

                if (!connected)
                {
                    _logger.LogWarning("Failed to establish RabbitMQ connection after max retries. Retrying in 30 seconds...");
                    await Task.Delay(30000, stoppingToken);
                }
            }
        }
    }
}