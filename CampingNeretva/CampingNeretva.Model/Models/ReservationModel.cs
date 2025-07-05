using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.Models
{
    public class ReservationModel
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int ParcelId { get; set; }
        public DateTime CheckInDate { get; set; }
        public DateTime CheckOutDate { get; set; }
        public decimal TotalPrice { get; set; }
        public string PaymentStatus { get; set; }
        public ParcelModel Parcel { get; set; }
        public UserModel User { get; set; }
        public List<ReservationPersonModel> ReservationPeople { get; set; }
        public List<ReservationVehicleModel> ReservationVehicles { get; set; }
        public List<ReservationAccommodationModel> ReservationAccommodations { get; set; }
        public List<ReservationRentableItemModel> ReservationRentables { get; set; }
        public List<ActivityModel> Activities { get; set; }
    }
}
