using CampingNeretva.Model.emailHelpers;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using CampingNeretva.Model.Models;

namespace CampingNeretva.Service.NotificationService
{
    public class EmailService
    {
        private readonly EmailSettings _settings;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IOptions<EmailSettings> options, ILogger<EmailService> logger)
        {
            _settings = options.Value ?? throw new ArgumentNullException(nameof(options));
            _logger = logger;
        }

        public async Task SendReservationConfirmation(string email, string firstName, ReservationModel reservation)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Camping Neretva", _settings.SmtpUser));
            message.To.Add(new MailboxAddress(firstName, email));
            message.Subject = "Reservation Confirmed ✔";

            message.Body = new TextPart("plain")
            {
                Text = $"Hello {firstName},\n\n" +
                       $"Your reservation #{reservation.ReservationId} is confirmed.\n" +
                       $"Check-In: {reservation.CheckInDate:yyyy-MM-dd}\n" +
                       $"Check-Out: {reservation.CheckOutDate:yyyy-MM-dd}\n" +
                       $"Total Price: {reservation.TotalPrice:C}\n\n" +
                       $"Thank you for choosing Camping Neretva!"
            };

            try
            {
                using var client = new SmtpClient();
                _logger.LogInformation($"Connecting to SMTP server {_settings.SmtpHost}:{_settings.SmtpPort}");
                await client.ConnectAsync(_settings.SmtpHost, _settings.SmtpPort, SecureSocketOptions.StartTls);
                _logger.LogInformation("Connected to SMTP server, authenticating...");
                await client.AuthenticateAsync(_settings.SmtpUser, _settings.SmtpPass);
                await client.SendAsync(message);
                await client.DisconnectAsync(true);
                _logger.LogInformation($"✅ Email sent to {email} for reservation #{reservation.ReservationId}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send email to {email} for reservation #{reservation.ReservationId}");
                throw;
            }
        }
    }
}