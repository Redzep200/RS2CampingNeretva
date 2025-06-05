using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class CreatePayPalOrderRequest
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EUR"; 
        public string ReturnUrl { get; set; }
        public string CancelUrl { get; set; }
    }
}
