using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.ImageModels
{
    public class ImageModel
    {
        public int ImageId { get; set; }
        public string Path { get; set; }
        public DateTime DateCreated { get; set; }
        public string ContentType { get; set; }
    }
}
