using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class PaymentInsertRequest
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string? PayPalOrderId { get; set; }
        public string? PayPalPaymentId { get; set; }
        public string Status { get; set; } = "PENDING";
    }
}
