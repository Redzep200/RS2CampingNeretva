using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : BaseCRUDController<PaymentModel, BaseSearchObject, PaymentInsertRequest, PaymentUpdateRequest>
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService) : base(paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost("create-paypal-order")]
        public async Task<IActionResult> CreatePayPalOrder([FromBody] CreatePayPalOrderRequest request)
        {
            try
            {
                var result = await _paymentService.CreatePayPalOrder(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("capture-paypal-order")]
        public async Task<IActionResult> CapturePayPalOrder([FromBody] CapturePayPalOrderRequest request)
        {
            try
            {
                var result = await _paymentService.CapturePayPalOrder(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("reservation/{reservationId}")]
        public async Task<IActionResult> GetPaymentsByReservation(int reservationId)
        {
            try
            {
                var payments = await _paymentService.GetPaymentsByReservationId(reservationId);
                return Ok(payments);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}