using CampingNeretva.Model;
using CampingNeretva.Model.emailHelpers;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;
using System;
using System.Threading.Tasks;

namespace CampingNeretva.Service.NotificationService
{
    public class EmailService
    {
        private readonly EmailSettings _settings;

        public EmailService(IOptions<EmailSettings> options)
        {
            _settings = options.Value;
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

            using var client = new SmtpClient();
            await client.ConnectAsync(_settings.SmtpHost, _settings.SmtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(_settings.SmtpUser, _settings.SmtpPass);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);

            Console.WriteLine($"✅ Email sent to {email}");
        }
    }
}
