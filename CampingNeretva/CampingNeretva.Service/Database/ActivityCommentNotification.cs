using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ActivityCommentNotification
{
    public int NotificationId { get; set; }

    public int ActivityId { get; set; }

    public string Category { get; set; } = null!;

    public string Sentiment { get; set; } = null!;

    public string Summary { get; set; } = null!;

    public string RelatedCommentIds { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateTime DateCreated { get; set; }

    public DateTime? DateReviewed { get; set; }

    public int? ReviewedBy { get; set; }
    public virtual Activity Activity { get; set; } = null!;
    public virtual User? ReviewedByNavigation { get; set; }
}
