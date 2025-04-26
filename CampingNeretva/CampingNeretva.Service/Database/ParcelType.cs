using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ParcelType
{
    public int ParcelTypeId { get; set; }

    public string? ParcelType1 { get; set; }

    public virtual ICollection<Parcel> Parcels { get; set; } = new List<Parcel>();
}
