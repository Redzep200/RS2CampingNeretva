using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class ReservationUpdateRequest
    {
        public DateTime? CheckInDate { get; set; }
        public DateTime? CheckOutDate { get; set; }
        public decimal? TotalPrice { get; set; }
        public string? PaymentStatus { get; set; }
    }
}
