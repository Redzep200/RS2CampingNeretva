using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Payment
{
    public int PaymentId { get; set; }

    public int ReservationId { get; set; }

    public int UserId { get; set; }

    public decimal Amount { get; set; }

    public DateTime TransactionDate { get; set; }

    public string? PayPalOrderId { get; set; }

    public string? PayPalPaymentId { get; set; }

    public string? Status { get; set; }

    public virtual Reservation Reservation { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
