using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class PersonImage
{
    public int PersonImageId { get; set; }

    public int PersonId { get; set; }

    public int ImageId { get; set; }

    public virtual Image Image { get; set; } = null!;

    public virtual Person Person { get; set; } = null!;
}
