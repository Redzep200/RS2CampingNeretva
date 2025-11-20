using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class ActivityCommentModel
    {
        public int ActivityCommentId { get; set; }
        public int ActivityId { get; set; }
        public int UserId { get; set; }
        public string CommentText { get; set; }
        public int Rating { get; set; }
        public DateTime DatePosted { get; set; }
    }
}
