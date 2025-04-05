using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ActivityUpdateRequest
    {
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime Date { get; set; }
        public decimal Price { get; set; }
        public int FacilityId { get; set; }
    }
}
