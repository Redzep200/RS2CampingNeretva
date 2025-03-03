using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ReservationAccommodation
{
    public int ReservationId { get; set; }

    public int AccommodationId { get; set; }

    public int Quantity { get; set; }

    public virtual Accommodation Accommodation { get; set; } = null!;

    public virtual Reservation Reservation { get; set; } = null!;
}
