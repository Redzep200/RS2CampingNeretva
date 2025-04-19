using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Person
{
    public int PersonId { get; set; }

    public string Type { get; set; } = null!;

    public decimal PricePerNight { get; set; }

    public virtual ICollection<PersonImage> PersonImages { get; set; } = new List<PersonImage>();

    public virtual ICollection<ReservationPerson> ReservationPeople { get; set; } = new List<ReservationPerson>();
}
