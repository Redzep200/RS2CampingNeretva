using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class ActivityImageModel
    {
        public int ActivityImageId { get; set; }
        public int ActivityId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
