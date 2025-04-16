using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model
{
    public class WorkerModel
    {
        public int WorkerId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public List<RoleModel> Roles { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }
    }
}
