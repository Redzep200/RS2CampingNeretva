using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int UserId { get; set; }
        public int ParcelId { get; set; }
        public DateTime CheckInDate { get; set; }
        public DateTime CheckOutDate { get; set; }
        public decimal TotalPrice { get; set; }
        public string PaymentStatus { get; set; }
        public List<RentableItemSelection> RentableItems { get; set; } = new List<RentableItemSelection>();
        public List<PersonSelection> Persons { get; set; } = new List<PersonSelection>();
        public List<AccommodationSelection> Accommodations { get; set; } = new List<AccommodationSelection>();
        public List<VehicleSelection> Vehicles { get; set; } = new List<VehicleSelection>();
        public List<ActivitySelection> Activities { get; set; } = new List<ActivitySelection>();

    }

    public class RentableItemSelection
    {
        public int ItemId { get; set; }
        public int Quantity { get; set; }
    }

    public class PersonSelection
    {
        public int PersonId { get; set; }
        public int Quantity { get; set; }
    }

    public class AccommodationSelection
    {
        public int AccommodationId { get; set; }
        public int Quantity { get; set; }
    }

    public class VehicleSelection
    {
        public int VehicleId { get; set; }
        public int Quantity { get; set; }
    }

    public class ActivitySelection
    {
        public int ActivityId { get; set; }
    }
}
