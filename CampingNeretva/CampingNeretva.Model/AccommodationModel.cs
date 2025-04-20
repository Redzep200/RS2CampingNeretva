using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model
{
    public class AccommodationModel
    {
        public int AccommodationId { get; set; }
        public string Type { get; set; }
        public decimal PricePerNight { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
