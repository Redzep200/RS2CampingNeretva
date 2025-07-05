using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class ReservationPersonModel
    {
        public int Quantity { get; set; }
        public PersonModel Person { get; set; }
    }
}
