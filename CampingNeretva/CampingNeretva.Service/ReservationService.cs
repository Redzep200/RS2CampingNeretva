using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using EasyNetQ;
using EasyNetQ.DI;
using EasyNetQ.Serialization.NewtonsoftJson;
using Microsoft.Extensions.Logging;

namespace CampingNeretva.Service
{
    public class ReservationService : BaseCRUDService<ReservationModel, ReservationSearchObject, Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        private readonly ILogger<ReservationService> _logger;

        public ReservationService(_200012Context context, IMapper mapper, ILogger<ReservationService> logger)
            : base(context, mapper)
        {
            _logger = logger;
        }

        public override IQueryable<Reservation> AddFilter(ReservationSearchObject search, IQueryable<Reservation> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search?.UserId.HasValue == true)
                filteredQuery = filteredQuery.Where(r => r.UserId == search.UserId);

            if (search?.ParcelId.HasValue == true)
                filteredQuery = filteredQuery.Where(r => r.ParcelId == search.ParcelId);

            if (search?.CheckInDate.HasValue == true)
                filteredQuery = filteredQuery.Where(r => r.CheckInDate >= search.CheckInDate);

            if (search?.CheckOutDate.HasValue == true)
                filteredQuery = filteredQuery.Where(r => r.CheckOutDate <= search.CheckOutDate);

            if (search?.IsPersonsIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationPeople).ThenInclude(rp => rp.Person);
            }

            if (search?.IsVehicleIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationVehicles).ThenInclude(rv => rv.Vehicle);
            }

            if (search?.IsAccommodationIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationAccommodations).ThenInclude(ra => ra.Accommodation);
            }

            if (search?.IsRentableItemsIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationRentables).ThenInclude(rr => rr.Item);
            }

            if (search?.IsActivitiesIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Activities);
            }

            if (search?.IsParcelIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Parcel).ThenInclude(p => p.ParcelAccommodation)
                .Include(x => x.Parcel).ThenInclude(p => p.ParcelType);
            }

            if (search?.IsUserIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.User).ThenInclude(x => x.UserType);
            }

            return filteredQuery;
        }

        public override void beforeInsert(ReservationInsertRequest request, Reservation entity)
        {
            decimal totalPrice = 0;
            var days = (request.CheckOutDate - request.CheckInDate).Days;

            var overlappingReservation = _context.Reservations
                .Where(r => r.ParcelId == request.ParcelId)
                .Where(r =>
                    r.CheckInDate < request.CheckOutDate &&
                    r.CheckOutDate > request.CheckInDate)
                .FirstOrDefault();

            if (overlappingReservation != null)
            {
                throw new Exception("Parcel is already reserved for the selected dates.");
            }

            if (request.RentableItems != null && request.RentableItems.Any())
            {
                foreach (var ri in request.RentableItems)
                {
                    var item = _context.RentableItems.Find(ri.ItemId);
                    if (item != null)
                    {
                        totalPrice += item.PricePerDay * ri.Quantity * days;
                    }
                }
            }

            foreach (var acc in request.Accommodations)
            {
                var accommodation = _context.Accommodations.Find(acc.AccommodationId);
                if (accommodation != null)
                {
                    totalPrice += accommodation.PricePerNight * acc.Quantity * days;
                }
            }

            foreach (var person in request.Persons)
            {
                var p = _context.Persons.Find(person.PersonId);
                if (p != null)
                {
                    totalPrice += p.PricePerNight * person.Quantity * days;
                }
            }

            foreach (var vehicle in request.Vehicles)
            {
                var v = _context.Vehicles.Find(vehicle.VehicleId);
                if (v != null)
                {
                    totalPrice += v.PricePerNight * vehicle.Quantity * days;
                }
            }

            if (request.Activities != null && request.Activities.Any())
            {
                foreach (var activity in request.Activities)
                {
                    var a = _context.Activities.Find(activity.ActivityId);
                    if (a != null)
                    {
                        totalPrice += a.Price;
                    }
                }
            }

            entity.TotalPrice = totalPrice;
            entity.PaymentStatus = "Pending";
        }

        public override async Task<ReservationModel> Insert(ReservationInsertRequest request)
        {
            var entity = Mapper.Map<Reservation>(request);

            beforeInsert(request, entity);

            entity.Activities = new List<Activity>();

            _context.Reservations.Add(entity);
            await _context.SaveChangesAsync();

            if (request.RentableItems != null && request.RentableItems.Any())
            {
                foreach (var ri in request.RentableItems)
                {
                    if (ri?.ItemId > 0)
                    {
                        var rentableItem = _context.RentableItems.Find(ri.ItemId);
                        if (rentableItem != null)
                        {
                            _context.ReservationRentables.Add(new ReservationRentable
                            {
                                ReservationId = entity.ReservationId,
                                ItemId = ri.ItemId,
                                Quantity = ri.Quantity
                            });
                        }
                    }
                }
            }

            foreach (var person in request.Persons)
                _context.ReservationPersons.Add(new ReservationPerson { ReservationId = entity.ReservationId, PersonId = person.PersonId, Quantity = person.Quantity });

            foreach (var acc in request.Accommodations)
                _context.ReservationAccommodations.Add(new ReservationAccommodation { ReservationId = entity.ReservationId, AccommodationId = acc.AccommodationId, Quantity = acc.Quantity });

            foreach (var vehicle in request.Vehicles)
                _context.ReservationVehicles.Add(new ReservationVehicle { ReservationId = entity.ReservationId, VehicleId = vehicle.VehicleId, Quantity = vehicle.Quantity });

            if (request.Activities != null && request.Activities.Any())
            {
                foreach (var act in request.Activities)
                    if (act?.ActivityId > 0)
                    {
                        var existingActivity = _context.Activities.Find(act.ActivityId);
                        if (existingActivity != null)
                        {
                            _context.Database.ExecuteSqlRaw(
                                "INSERT INTO ReservationActivities (ReservationId, ActivityId) VALUES ({0}, {1})",
                                entity.ReservationId, act.ActivityId);
                        }
                    }
            }

            var mappedEntity = Mapper.Map<ReservationModel>(entity);

            var bus = RabbitHutch.CreateBus("host=rabbitmq", x =>
            x.Register<EasyNetQ.ISerializer>(_ => new EasyNetQ.Serialization.NewtonsoftJson.NewtonsoftJsonSerializer()));
            await bus.PubSub.PublishAsync(mappedEntity);

            _context.SaveChanges();

            return mappedEntity;
        }

        public override async Task<PagedResult<ReservationModel>> GetPaged(ReservationSearchObject search)
        {
            return await base.GetPaged(search);
        }

        public override async Task<ReservationModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        public override async Task Delete(int id)
        {
            var item = await _context.Reservations.FindAsync(id);
            if (item == null)
            {
                throw new Exception("Reservation not found");
            }

            var relatedAccommodations = await _context.ReservationAccommodations.Where(x => x.ReservationId == id).ToListAsync();
            _context.ReservationAccommodations.RemoveRange(relatedAccommodations);

            var relatedPersons = await _context.ReservationPersons.Where(x => x.ReservationId == id).ToListAsync();
            _context.ReservationPersons.RemoveRange(relatedPersons);

            var relatedRentables = await _context.ReservationRentables.Where(x => x.ReservationId == id).ToListAsync();
            _context.ReservationRentables.RemoveRange(relatedRentables);

            var relatedVehicles = await _context.ReservationVehicles.Where(x => x.ReservationId == id).ToListAsync();
            _context.ReservationVehicles.RemoveRange(relatedVehicles);

            var relatedPayment = await _context.Payments.Where(x => x.ReservationId == id).ToListAsync();
            _context.Payments.RemoveRange(relatedPayment);

            _context.Database.ExecuteSqlRaw("DELETE FROM ReservationActivities WHERE ReservationId = {0}", id);

            _context.Reservations.Remove(item);
            await _context.SaveChangesAsync();
        }
    }
}