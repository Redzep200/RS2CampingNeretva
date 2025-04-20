using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class RentableItemImageModel
    {
        public int RentableItemImageId { get; set; }
        public int RentableItemId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
