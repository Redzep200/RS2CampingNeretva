using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class Review
{
    public int ReviewId { get; set; }

    public int UserId { get; set; }

    public int WorkerId { get; set; }

    public int Rating { get; set; }

    public string Comment { get; set; } = null!;

    public DateTime DatePosted { get; set; }

    public virtual User User { get; set; } = null!;

    public virtual Worker Worker { get; set; } = null!;
}
