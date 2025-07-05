using System;
using System.Collections.Generic;
using System.Text;
using CampingNeretva.Model.ImageModels;

namespace CampingNeretva.Model.Models
{
    public class RentableItemModel
    {
        public int ItemId { get; set; }
        public int TotalQuantity { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public decimal PricePerDay { get; set; }
        public int AvailableQuantity { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
