using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class ReservationVehicleModel
    {
        public int VehicleId { get; set; }
        public int Quantity { get; set; }
        public VehicleModel Vehicle { get; set; }
    }
}
