using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class VehicleImageModel
    {
        public int VehicleImageId { get; set; }
        public int VehicleId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
