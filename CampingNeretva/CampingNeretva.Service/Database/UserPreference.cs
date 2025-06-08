using System;
using System.Collections.Generic;

namespace CampingNeretva.Service.Database;

public partial class UserPreference
{
    public int UserPreferenceId { get; set; }

    public int UserId { get; set; }

    public int NumberOfPeople { get; set; }

    public bool HasSmallChildren { get; set; }

    public bool HasSeniorTravelers { get; set; }

    public string CarLength { get; set; } = null!;

    public bool HasDogs { get; set; }

    public virtual User User { get; set; } = null!;
}
