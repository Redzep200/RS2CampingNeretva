using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{ 
    public class ReservationRentableItemModel
    {
        //public int RentableItemId { get; set; }
        public int Quantity { get; set; }
        public RentableItemModel Item { get; set; }
    }
}
