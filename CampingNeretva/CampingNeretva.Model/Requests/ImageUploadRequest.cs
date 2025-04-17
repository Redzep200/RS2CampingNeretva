using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ImageUploadRequest
    {
        public IFormFile Image { get; set; }
    }
}
