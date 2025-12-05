using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.DTO
{
    public class ActivityCommentDto
    {
        public int ActivityCommentId { get; set; }
        public string CommentText { get; set; }
        public int Rating { get; set; }
        public DateTime DatePosted { get; set; }
    }
}
