using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.emailHelpers
{
    public class EmailSettings
    {
        public string SmtpHost { get; set; }
        public int SmtpPort { get; set; }
        public string SmtpUser { get; set; }
        public string SmtpPass { get; set; }
    }
}
