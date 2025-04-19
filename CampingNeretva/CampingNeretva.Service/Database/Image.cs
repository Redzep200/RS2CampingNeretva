using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Image
{
    public int ImageId { get; set; }

    public string Path { get; set; } = null!;

    public DateTime? DateCreated { get; set; }

    public string? ContentType { get; set; }

    public virtual ICollection<AccommodationImage> AccommodationImages { get; set; } = new List<AccommodationImage>();

    public virtual ICollection<ActivityImage> ActivityImages { get; set; } = new List<ActivityImage>();

    public virtual ICollection<FacilityImage> FacilityImages { get; set; } = new List<FacilityImage>();

    public virtual ICollection<ParcelImage> ParcelImages { get; set; } = new List<ParcelImage>();

    public virtual ICollection<PersonImage> PersonImages { get; set; } = new List<PersonImage>();

    public virtual ICollection<RentableItemImage> RentableItemImages { get; set; } = new List<RentableItemImage>();

    public virtual ICollection<VehicleImage> VehicleImages { get; set; } = new List<VehicleImage>();
}
