using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class FacilityImage
{
    public int FacilityImageId { get; set; }

    public int FacilityId { get; set; }

    public int ImageId { get; set; }

    public virtual Facility Facility { get; set; } = null!;

    public virtual Image Image { get; set; } = null!;
}
