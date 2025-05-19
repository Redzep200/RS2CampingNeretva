using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class FacilityUpdateRequest
    {
        public string? FacilityType { get; set; }
        public string? Description { get; set; }
        public int? ImageId { get; set; }
    }
}
