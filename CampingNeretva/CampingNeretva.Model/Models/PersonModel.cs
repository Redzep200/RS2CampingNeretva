using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model.Models
{
    public class PersonModel
    {
        public int PersonId { get; set; }
        public string Type { get; set; }
        public decimal PricePerNight { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();

    }
}
