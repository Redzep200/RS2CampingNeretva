using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class RentableItemSearchObject : BaseSearchObject
    {
        public string? NameGTE { get; set; }
        public decimal? PricePerDayGTE { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
    }
}
