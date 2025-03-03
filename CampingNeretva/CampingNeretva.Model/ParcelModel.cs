using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ParcelModel
    {
        public int ParcelId { get; set; }
        public string ParcelNumber { get; set; }
        public bool Shade { get; set; }
        public bool Electricity { get; set; }
        public string Description { get; set; }
        public string AvailabilityStatus { get; set; }
    }
}
