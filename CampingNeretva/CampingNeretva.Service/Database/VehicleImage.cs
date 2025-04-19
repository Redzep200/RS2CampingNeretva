using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class VehicleImage
{
    public int VehicleImageId { get; set; }

    public int VehicleId { get; set; }

    public int ImageId { get; set; }

    public virtual Image Image { get; set; } = null!;

    public virtual Vehicle Vehicle { get; set; } = null!;
}
