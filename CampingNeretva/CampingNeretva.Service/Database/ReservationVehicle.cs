using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class ReservationVehicle
{
    public int ReservationId { get; set; }

    public int VehicleId { get; set; }

    public int Quantity { get; set; }

    public virtual Reservation Reservation { get; set; } = null!;

    public virtual Vehicle Vehicle { get; set; } = null!;
}
