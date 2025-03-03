using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Parcel
{
    public int ParcelId { get; set; }

    public int ParcelNumber { get; set; }

    public bool Shade { get; set; }

    public bool Electricity { get; set; }

    public string? Description { get; set; }

    public bool AvailabilityStatus { get; set; }

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
}
