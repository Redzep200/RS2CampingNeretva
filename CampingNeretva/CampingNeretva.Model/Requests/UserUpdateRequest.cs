using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class UserUpdateRequest
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public string? PhoneNumber { get; set; }
    }
}
