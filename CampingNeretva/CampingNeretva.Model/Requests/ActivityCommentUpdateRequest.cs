using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ActivityCommentUpdateRequest
    {
        public string CommentText { get; set; }
        public int Rating { get; set; }
    }
}
