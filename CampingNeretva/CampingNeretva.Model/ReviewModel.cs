using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ReviewModel
    {
        public int ReviewId { get; set; }
        public WorkerModel Worker { get; set; }
        public UserModel User { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime DatePosted { get; set; }
    }
}
