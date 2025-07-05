using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model.Models
{
    public class ParcelModel
    {
        public int ParcelId { get; set; }
        public int ParcelNumber { get; set; }
        public bool Shade { get; set; }
        public bool Electricity { get; set; }
        public string? Description { get; set; }
        public bool AvailabilityStatus { get; set; }
        public ParcelAccommodationModel ParcelAccommodation { get; set; }
        public ParcelTypeModel ParcelType { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
