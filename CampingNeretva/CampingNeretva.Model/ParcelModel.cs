using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ParcelModel
    {
        public int ParcelId { get; set; }
        public int ParcelNumber { get; set; }
        public bool Shade { get; set; }
        public bool Electricity { get; set; }
        public string? Description { get; set; }
        public bool AvailabilityStatus { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
