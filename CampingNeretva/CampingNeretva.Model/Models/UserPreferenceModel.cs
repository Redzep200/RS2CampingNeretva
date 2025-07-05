using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class UserPreferenceModel
    {
        public int UserPreferenceId { get; set; }
        public int UserId { get; set; }
        public int NumberOfPeople { get; set; }
        public bool HasSmallChildren { get; set; }
        public bool HasSeniorTravelers { get; set; }
        public string CarLength { get; set; }
        public bool HasDogs { get; set; }
    }
}
