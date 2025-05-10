using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? ReviewIdGTE { get; set; }
        public DateTime? DatePostedGTE { get; set; }
        public bool? IsUserIncluded { get; set; }
        public bool? IsWorkerIncluded { get; set; }
        public int? WorkerId { get; set; }
        public int? UserId { get; set; }

    }
}
