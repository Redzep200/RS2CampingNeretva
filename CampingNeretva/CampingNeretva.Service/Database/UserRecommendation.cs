using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class UserRecommendation
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int? ParcelId1 { get; set; }

    public int? ParcelId2 { get; set; }

    public int? ParcelId3 { get; set; }

    public int? ActivityId1 { get; set; }

    public int? ActivityId2 { get; set; }

    public int? RentableItemId1 { get; set; }

    public int? RentableItemId2 { get; set; }

    public virtual User User { get; set; } = null!;
}
