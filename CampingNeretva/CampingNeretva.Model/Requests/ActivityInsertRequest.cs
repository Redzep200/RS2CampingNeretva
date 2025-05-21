using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ActivityInsertRequest
    {
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime Date { get; set; }
        public decimal Price { get; set; }
        public int? FacilityId { get; set; }
        public int ImageId { get; set; }
    }
}
