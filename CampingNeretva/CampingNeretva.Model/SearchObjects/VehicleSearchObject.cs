using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class VehicleSearchObject : BaseSearchObject
    {
        public string? TypeGTE { get; set; }
        public decimal? PricePerNightGTE { get; set; }
    }
}
