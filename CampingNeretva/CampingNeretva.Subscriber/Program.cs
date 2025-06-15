using CampingNeretva.Model;
using EasyNetQ;
using EasyNetQ.DI;
using System;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        using var bus = RabbitHutch.CreateBus("host=rabbitmq;username=guest;password=guest;timeout=60", x =>
            x.Register<ISerializer>(_ => new EasyNetQ.Serialization.NewtonsoftJson.NewtonsoftJsonSerializer()));

        await bus.PubSub.SubscribeAsync<ReservationModel>("seminarski", msg =>
        {
            Console.WriteLine($"Reservation created: {msg.CheckInDate} - {msg.CheckOutDate}");
        });

        Console.WriteLine("Listening for messages. Press Ctrl+C to exit.");
        await Task.Delay(Timeout.Infinite, CancellationToken.None); 
    }
}