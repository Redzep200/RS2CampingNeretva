using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ActivitySearchObject
    {
        public string? NameGTE { get; set; }
        public decimal? Price { get; set; }
        public bool? IsFacilityTypeIncluded { get; set; }
        public int? Page { get; set; }
        public int? PageSize { get; set; }
    }
}
