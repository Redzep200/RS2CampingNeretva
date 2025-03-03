using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class RentableItem
{
    public int ItemId { get; set; }

    public int TotalQuantity { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public decimal PricePerDay { get; set; }

    public bool AvailabilityStatus { get; set; }

    public virtual ICollection<ReservationRentable> ReservationRentables { get; set; } = new List<ReservationRentable>();
}
