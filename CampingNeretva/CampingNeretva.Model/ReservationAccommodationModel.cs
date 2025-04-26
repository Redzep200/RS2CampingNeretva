using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ReservationAccommodationModel
    {
        //public int AccommodationId { get; set; }
        public int Quantity { get; set; }
        public AccommodationModel Accommodation { get; set; }
    }
}
