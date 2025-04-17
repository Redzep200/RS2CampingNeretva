using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ParcelImage
{
    public int ParcelImageId { get; set; }

    public int ParcelId { get; set; }

    public int ImageId { get; set; }

    public virtual Image Image { get; set; } = null!;

    public virtual Parcel Parcel { get; set; } = null!;
}
