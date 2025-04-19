using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class PersonImageModel
    {
        public int PersonImageId { get; set; }
        public int PersonId { get; set; }
        public int ImageId { get; set; }
        public ImageModel Image { get; set; }
    }
}
