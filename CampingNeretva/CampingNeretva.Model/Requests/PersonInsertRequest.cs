﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Requests
{
    public class PersonInsertRequest
    {
        public string Type { get; set; }
        public decimal PricePerNight { get; set; }
    }
}
