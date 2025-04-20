using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model
{
    public class FacilityModel
    {
        public int FacilityId { get; set; }

        public string FacilityType { get; set; }
        public string? Description { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
