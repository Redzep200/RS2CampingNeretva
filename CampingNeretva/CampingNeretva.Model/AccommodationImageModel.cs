using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class AccommodationImageModel
    {
        public int AccommodationImageId { get; set; }
        public int AccommodationId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
