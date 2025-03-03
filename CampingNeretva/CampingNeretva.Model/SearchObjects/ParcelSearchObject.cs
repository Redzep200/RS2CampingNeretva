using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ParcelSearchObject
    {
        public int? ParcelNumberGTE { get; set; }
        public bool? ShadeGTE { get; set; }
        public bool? ElectricityGTE { get; set; }
        public bool? AvailabilityStatusGTE { get; set; }
    }
}
