using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Image
{
    public int ImageId { get; set; }

    public string Path { get; set; } = null!;

    public DateTime? DateCreated { get; set; }

    public string? ContentType { get; set; }

    public virtual ICollection<ParcelImage> ParcelImages { get; set; } = new List<ParcelImage>();
}
