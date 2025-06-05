using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Responses
{
    public class PayPalOrderResponse
    {
        public string OrderId { get; set; }
        public string ApprovalUrl { get; set; }
        public string Status { get; set; }
    }
}
