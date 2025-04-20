using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class ParcelImageModel
    {
        public int ParcelImageId { get; set; }
        public int ParcelId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
