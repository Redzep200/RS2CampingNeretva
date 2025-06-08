using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using EasyNetQ;
using System.Threading;
using System.Threading.Tasks;
using EasyNetQ.DI;
using EasyNetQ.Serialization.NewtonsoftJson;

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
            var bus = RabbitHutch.CreateBus("host=localhost", x =>
                x.Register<EasyNetQ.ISerializer>(_ => new EasyNetQ.Serialization.NewtonsoftJson.NewtonsoftJsonSerializer()));

            await bus.PubSub.SubscribeAsync<ReservationModel>("email_service", async reservation =>
            {
                using var scope = _scopeFactory.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<_200012Context>();
                var emailService = scope.ServiceProvider.GetRequiredService<EmailService>();

                var user = await db.Users.FindAsync(reservation.UserId);
                if (user != null)
                {
                    await emailService.SendReservationConfirmation(user.Email, user.FirstName, reservation);
                    _logger.LogInformation($"✅ Email sent to {user.Email}");
                }
                else
                {
                    _logger.LogWarning($"❌ User not found for reservation #{reservation.ReservationId}");
                }
            }, cancellationToken: stoppingToken);
        }
    }
}
