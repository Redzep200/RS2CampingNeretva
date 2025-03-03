using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Facility
{
    public int FacilityId { get; set; }

    public string? Description { get; set; }

    public string? FacilityType { get; set; }

    public virtual ICollection<Activity> Activities { get; set; } = new List<Activity>();
}
