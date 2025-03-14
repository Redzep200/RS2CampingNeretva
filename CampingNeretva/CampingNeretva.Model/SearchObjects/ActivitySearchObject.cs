using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ActivitySearchObject : BaseSearchObject
    {
        public string? NameGTE { get; set; }
        public decimal? Price { get; set; }
        public bool? IsFacilityTypeIncluded { get; set; }
    }
}
