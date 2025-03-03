using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class UserSearchObject
    {
        public string? FirstNameGTE { get; set; }
        public string? LastNameGTE { get; set; }
        public string? UserNameGTE { get; set; }
        public string? EmailGTE { get; set; }
    }
}
