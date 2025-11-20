using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class ActivityCommentSearchObject : BaseSearchObject
    {
        public int? ActivityId { get; set; }
        public int? UserId { get; set; }
        public int? Rating { get; set; }
    }
}
