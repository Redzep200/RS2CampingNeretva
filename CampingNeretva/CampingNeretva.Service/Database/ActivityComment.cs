using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ActivityComment
{
    public int ActivityCommentId { get; set; }

    public int ActivityId { get; set; }

    public int UserId { get; set; }

    public string CommentText { get; set; } = null!;

    public int Rating { get; set; }

    public DateTime DatePosted { get; set; }
    public virtual Activity Activity { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}
