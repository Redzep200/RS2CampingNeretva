using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ParcelInsertRequest
    {
        public int ParcelNumber { get; set; }
        public bool Shade { get; set; }
        public bool Electricity { get; set; }
        public string? Description { get; set; }
    }
}
