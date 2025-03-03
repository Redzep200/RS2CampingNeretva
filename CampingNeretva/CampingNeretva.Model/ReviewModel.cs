using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ReviewModel
    {
        public int ReviewId { get; set; }
        //public int UserId { get; set; }
        //public int WorkerId { get; set; }

        public string UserName { get; set; }
        public string Worker { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime DatePosted { get; set; }
    }
}
