using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class CapturePayPalOrderRequest
    {
        public string OrderId { get; set; }
        public int ReservationId { get; set; }
        public int UserId { get; set; }
    }
}
