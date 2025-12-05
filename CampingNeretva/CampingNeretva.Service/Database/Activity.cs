using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Activity
{
    public int ActivityId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public DateTime Date { get; set; }

    public decimal Price { get; set; }

    public int? FacilityId { get; set; }

    public virtual ICollection<ActivityImage> ActivityImages { get; set; } = new List<ActivityImage>();

    public virtual Facility? Facility { get; set; }

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Worker> Workers { get; set; } = new List<Worker>();
    public virtual ICollection<ActivityComment> ActivityComments { get; set; } = new List<ActivityComment>();
    public virtual ICollection<ActivityCommentNotification> ActivityCommentNotifications { get; set; } = new List<ActivityCommentNotification>();
}
