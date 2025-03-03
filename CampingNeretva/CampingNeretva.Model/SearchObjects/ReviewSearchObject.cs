using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ReviewSearchObject
    {
        public int? WorkerIdGTE { get; set; }
        public DateTime? DatePostedGTE { get; set; }
    }
}
