using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class ReservationModel
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int ParcelId { get; set; }
        public DateTime CheckInDate { get; set; }
        public DateTime CheckOutDate { get; set; }
        public decimal TotalPrice { get; set; }
        public string PaymentStatus { get; set; }
    }
}
