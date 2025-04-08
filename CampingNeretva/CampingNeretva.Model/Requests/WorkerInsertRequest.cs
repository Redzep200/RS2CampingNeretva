using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class WorkerInsertRequest
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int[] Roles { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }
    }
}
