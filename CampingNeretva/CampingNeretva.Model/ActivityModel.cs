using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model
{
    public class ActivityModel
    {
        public int ActivityId { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime Date { get; set; }
        public decimal Price { get; set; }
        public FacilityModel? Facility { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
