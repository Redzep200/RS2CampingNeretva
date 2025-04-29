using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ParcelUpdateRequest
    {
        public string? Description { get; set; }
        public bool AvailabilityStatus { get; set; }
        public int ParcelAccommodationId { get; set; }
        public int ParcelTypeId { get; set; }
    }
}
