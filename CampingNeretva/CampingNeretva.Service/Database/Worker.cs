using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Worker
{
    public int WorkerId { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Email { get; set; }

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<Activity> Activities { get; set; } = new List<Activity>();

    public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
}
