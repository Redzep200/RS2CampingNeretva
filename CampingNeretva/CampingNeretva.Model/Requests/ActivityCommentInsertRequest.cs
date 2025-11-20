using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ActivityCommentInsertRequest
    {
        public int ActivityId { get; set; }
        public int UserId { get; set; }
        public string CommentText { get; set; }
        public int Rating { get; set; }
    }
}
