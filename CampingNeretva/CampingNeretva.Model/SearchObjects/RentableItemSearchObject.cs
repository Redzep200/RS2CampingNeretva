using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class RentableItemSearchObject
    {
        public string? NameGTE { get; set; }
        public decimal? PricePerDayGTE { get; set; }
    }
}
