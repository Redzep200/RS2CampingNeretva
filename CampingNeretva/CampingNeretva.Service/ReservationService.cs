using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service
{
    public class ReservationService : BaseCRUDService<ReservationModel, ReservationSearchObject, Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        public ReservationService(_200012Context context, IMapper mapper)
            : base(context, mapper)
        {
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
                filteredQuery = filteredQuery.Include(x => x.ReservationPeople).ThenInclude(rp=>rp.Person);
            }

            if (search?.IsVehicleIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationVehicles).ThenInclude(rv=>rv.Vehicle);
            }

            if (search?.IsAccommodationIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationAccommodations).ThenInclude(ra=>ra.Accommodation);
            }

            if (search?.IsRentableItemsIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ReservationRentables).ThenInclude(rr=>rr.Item);
            }

            if (search?.IsActivitiesIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Activities);
            }
            return filteredQuery;
        }

        public override void beforeInsert(ReservationInsertRequest request, Reservation entity)
        {
            decimal totalPrice = 0;
            var days = (request.CheckOutDate - request.CheckInDate).Days;

            // Rentable items
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

            // Accommodations
            foreach (var acc in request.Accommodations)
            {
                var accommodation = _context.Accommodations.Find(acc.AccommodationId);
                if (accommodation != null)
                {
                    totalPrice += accommodation.PricePerNight * acc.Quantity * days;
                }
            }

            // People
            foreach (var person in request.Persons)
            {
                var p = _context.Persons.Find(person.PersonId);
                if (p != null)
                {
                    totalPrice += p.PricePerNight * person.Quantity * days;
                }
            }

            // Vehicles
            foreach (var vehicle in request.Vehicles)
            {
                var v = _context.Vehicles.Find(vehicle.VehicleId);
                if (v != null)
                {
                    totalPrice += v.PricePerNight * vehicle.Quantity * days;
                }
            }

            // Activities (charged once per activity per reservation)
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

        public override ReservationModel Insert(ReservationInsertRequest request)
        {
            var entity = Mapper.Map<Reservation>(request);

            beforeInsert(request, entity);

            entity.Activities = new List<Activity>();

            _context.Reservations.Add(entity);
            _context.SaveChanges();

            if (request.RentableItems != null && request.RentableItems.Any())
            {
                foreach (var ri in request.RentableItems)
                {
                    _context.ReservationRentables.Add(new ReservationRentable
                    {
                        ReservationId = entity.ReservationId,
                        ItemId = ri.ItemId,
                        Quantity = ri.Quantity
                    });
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
                {
                    _context.Database.ExecuteSqlRaw(
                        "INSERT INTO ReservationActivities (ReservationId, ActivityId) VALUES ({0}, {1})",
                        entity.ReservationId, act.ActivityId);
                }
            }

            _context.SaveChanges();

            return Mapper.Map<ReservationModel>(entity);
        }

        public override PagedResult<ReservationModel> GetPaged(ReservationSearchObject search)
        {
            return base.GetPaged(search);
        }

        public override ReservationModel GetById(int id)
        {
            return base.GetById(id);
        }

    }
}
