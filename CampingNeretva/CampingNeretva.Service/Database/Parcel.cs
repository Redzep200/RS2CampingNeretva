using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Parcel
{
    public int ParcelId { get; set; }

    public string? ParcelNumber { get; set; }

    public bool? Shade { get; set; }

    public bool? Electricity { get; set; }

    public string? Description { get; set; }

    public string? AvailabilityStatus { get; set; }

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
}
