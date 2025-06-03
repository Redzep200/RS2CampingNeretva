using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ParcelUpdateRequest
    {
        public int ParcelNumber { get; set; }
        public string? Description { get; set; }
        public bool Shade { get; set; }
        public bool Electricity { get; set; }
        public int ImageId { get; set; }
        public int ParcelAccommodationId { get; set; }
        public int ParcelTypeId { get; set; }
    }
}
