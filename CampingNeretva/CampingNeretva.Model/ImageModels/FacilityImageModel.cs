using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class FacilityImageModel
    {
        public int FacilityImageId { get; set; }
        public int FacilityId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
