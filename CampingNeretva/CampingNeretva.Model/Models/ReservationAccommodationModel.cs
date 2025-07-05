using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class ReservationAccommodationModel
    {
        public int Quantity { get; set; }
        public AccommodationModel Accommodation { get; set; }
    }
}
