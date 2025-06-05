using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.Responses;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IPaymentService : ICRUDService<PaymentModel, BaseSearchObject, PaymentInsertRequest, PaymentUpdateRequest>
    {
        Task<PayPalOrderResponse> CreatePayPalOrder(CreatePayPalOrderRequest request);
        Task<PayPalCaptureResponse> CapturePayPalOrder(CapturePayPalOrderRequest request);
        Task<List<PaymentModel>> GetPaymentsByReservationId(int reservationId);
    }
}
