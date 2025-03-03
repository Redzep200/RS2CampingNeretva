using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Reservation
{
    public int ReservationId { get; set; }

    public int UserId { get; set; }

    public int ParcelId { get; set; }

    public DateTime CheckInDate { get; set; }

    public DateTime CheckOutDate { get; set; }

    public decimal TotalPrice { get; set; }

    public string PaymentStatus { get; set; } = null!;

    public virtual Parcel Parcel { get; set; } = null!;

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual ICollection<ReservationAccommodation> ReservationAccommodations { get; set; } = new List<ReservationAccommodation>();

    public virtual ICollection<ReservationPerson> ReservationPeople { get; set; } = new List<ReservationPerson>();

    public virtual ICollection<ReservationRentable> ReservationRentables { get; set; } = new List<ReservationRentable>();

    public virtual ICollection<ReservationVehicle> ReservationVehicles { get; set; } = new List<ReservationVehicle>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<Activity> Activities { get; set; } = new List<Activity>();
}
