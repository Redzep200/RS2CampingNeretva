using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ActivitySearchObject
    {
        public string? NameGTE { get; set; }
        public decimal? PriceGTE { get; set; }
    }
}
