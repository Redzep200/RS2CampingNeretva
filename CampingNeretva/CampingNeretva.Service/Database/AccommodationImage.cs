using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class AccommodationImage
{
    public int AccommodationImageId { get; set; }

    public int AccommodationId { get; set; }

    public int ImageId { get; set; }

    public virtual Accommodation Accommodation { get; set; } = null!;

    public virtual Image Image { get; set; } = null!;
}
