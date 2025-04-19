using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ActivityImage
{
    public int ActivityImageId { get; set; }

    public int ActivityId { get; set; }

    public int ImageId { get; set; }

    public virtual Activity Activity { get; set; } = null!;

    public virtual Image Image { get; set; } = null!;
}
