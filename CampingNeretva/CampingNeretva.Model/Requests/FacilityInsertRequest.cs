using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class FacilityInsertRequest
    {
        public string FacilityType { get; set; }
        public string? Description { get; set; }
    }
}
