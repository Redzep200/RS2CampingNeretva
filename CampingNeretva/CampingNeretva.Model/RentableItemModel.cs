using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class RentableItemModel
    {
        public int ItemId { get; set; }
        public int TotalQuantity { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal PricePerDay { get; set; }
        public string AvailabilityStatus { get; set; }
    }
}
