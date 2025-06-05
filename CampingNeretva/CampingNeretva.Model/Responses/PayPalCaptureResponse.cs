using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Responses
{
    public class PayPalCaptureResponse
    {
        public string PaymentId { get; set; }
        public string Status { get; set; }
        public decimal Amount { get; set; }
        public DateTime TransactionDate { get; set; }
    }
}
