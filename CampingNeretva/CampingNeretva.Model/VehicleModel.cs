﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class VehicleModel
    {
        public int VehicleId { get; set; }
        public string Type { get; set; }
        public decimal PricePerNight { get; set; }
        public List<ImageModel> Images { get; set; } = new List<ImageModel>();
    }
}
