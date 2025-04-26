using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ParcelId { get; set; }
        public DateTime? CheckInDate { get; set; }
        public DateTime? CheckOutDate { get; set; }
        public bool? IsPersonsIncluded { get; set; }
        public bool? IsVehicleIncluded { get; set; }
        public bool? IsAccommodationIncluded { get; set; }
        public bool? IsRentableItemsIncluded { get; set; }
        public bool? IsActivitiesIncluded { get; set; }
    }
}
