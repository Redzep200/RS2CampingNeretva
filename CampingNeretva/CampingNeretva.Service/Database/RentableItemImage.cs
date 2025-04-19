using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class RentableItemImage
{
    public int RentableItemImageId { get; set; }

    public int RentableItemId { get; set; }

    public int ImageId { get; set; }

    public virtual Image Image { get; set; } = null!;

    public virtual RentableItem RentableItem { get; set; } = null!;
}
