using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ActivityModel
    {
        private FacilityModel facilityModel;

        public int ActivityId { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime Date { get; set; }
        public decimal Price { get; set; }
        public FacilityModel Facility { get; set; }
    }
}
