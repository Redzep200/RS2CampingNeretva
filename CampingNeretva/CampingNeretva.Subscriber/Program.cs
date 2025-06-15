using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using EasyNetQ;
using EasyNetQ.DI;
using System.Collections.Generic;

var bus = RabbitHutch.CreateBus("host=rabbitmq;username=guest;password=guest;timeout=60", x =>
    x.Register<ISerializer>(_ => new EasyNetQ.Serialization.NewtonsoftJson.NewtonsoftJsonSerializer()));

await bus.PubSub.SubscribeAsync<ReservationModel>("seminarski", msg => {
    Console.WriteLine($"Reservation created: {msg.CheckInDate} - {msg.CheckOutDate}");
});

Console.WriteLine("Listening for messages, press <return> key to close!");
Console.ReadLine();