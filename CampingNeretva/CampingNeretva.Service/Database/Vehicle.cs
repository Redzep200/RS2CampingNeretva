﻿using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Vehicle
{
    public int VehicleId { get; set; }

    public string Type { get; set; } = null!;

    public decimal PricePerNight { get; set; }

    public virtual ICollection<ReservationVehicle> ReservationVehicles { get; set; } = new List<ReservationVehicle>();

    public virtual ICollection<VehicleImage> VehicleImages { get; set; } = new List<VehicleImage>();
}
