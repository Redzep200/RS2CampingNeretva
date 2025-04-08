using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class RentableItemInsertRequest
    {
        public int TotalQuantity { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public decimal PricePerDay { get; set; }
    }
}
