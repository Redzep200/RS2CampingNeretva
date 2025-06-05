using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class PaymentUpdateRequest
    {
        public string? PayPalPaymentId { get; set; }
        public string Status { get; set; }
        public DateTime? TransactionDate { get; set; }
    }
}
