using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ParcelAccommodation
{
    public int ParcelAccommodationId { get; set; }

    public string? ParcelAccommodation1 { get; set; }

    public virtual ICollection<Parcel> Parcels { get; set; } = new List<Parcel>();
}
