using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ParcelSearchObject : BaseSearchObject
    {
        public int? ParcelNumber { get; set; }
        public bool? Shade { get; set; }
        public bool? Electricity { get; set; }
        public bool? AvailabilityStatus { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
    }
}
