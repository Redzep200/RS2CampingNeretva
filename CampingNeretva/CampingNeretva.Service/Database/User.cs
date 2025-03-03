using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class User
{
    public int UserId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? Email { get; set; }

    public string PasswordHash { get; set; } = null!;

    public string? PhoneNumber { get; set; }

    public string PasswordSalt { get; set; } = null!;

    public string UserName { get; set; } = null!;

    public int UserTypeId { get; set; }

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual UserType UserType { get; set; } = null!;
}
