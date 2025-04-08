using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int UserId { get; set; }
        public int WorkerId { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
    }
}
