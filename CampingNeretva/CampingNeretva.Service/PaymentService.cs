using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.Responses;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.Text;
using System.Text.Json;

namespace CampingNeretva.Service
{
    public class PaymentService : BaseCRUDService<PaymentModel, BaseSearchObject, Payment, PaymentInsertRequest, PaymentUpdateRequest>, IPaymentService
    {
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;
        private readonly string _paypalBaseUrl;
        private readonly string _clientId;
        private readonly string _clientSecret;

        public PaymentService(_200012Context context, IMapper mapper, IConfiguration configuration, HttpClient httpClient)
            : base(context, mapper)
        {
            _configuration = configuration;
            _httpClient = httpClient;
            _paypalBaseUrl = _configuration["PayPal:BaseUrl"] ?? "https://api-m.sandbox.paypal.com"; // Use sandbox for testing
            _clientId = _configuration["PayPal:ClientId"] ?? "";
            _clientSecret = _configuration["PayPal:ClientSecret"] ?? "";
        }

        public async Task<PayPalOrderResponse> CreatePayPalOrder(CreatePayPalOrderRequest request)
        {
            var accessToken = await GetPayPalAccessToken();

            var orderRequest = new
            {
                intent = "CAPTURE",
                purchase_units = new[]
                {
                    new
                    {
                        amount = new
                        {
                            currency_code = request.Currency,
                            value = request.Amount.ToString("F2")
                        },
                        description = $"Camping Neretva Reservation #{request.ReservationId}"
                    }
                },
                application_context = new
                {
                    return_url = request.ReturnUrl,
                    cancel_url = request.CancelUrl,
                    brand_name = "Camping Neretva",
                    landing_page = "BILLING",
                    user_action = "PAY_NOW"
                }
            };

            var json = JsonSerializer.Serialize(orderRequest);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {accessToken}");

            var response = await _httpClient.PostAsync($"{_paypalBaseUrl}/v2/checkout/orders", content);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"PayPal API Error: {responseContent}");
            }

            var orderResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
            var orderId = orderResponse.GetProperty("id").GetString();
            var links = orderResponse.GetProperty("links").EnumerateArray();
            var approvalUrl = links.FirstOrDefault(l =>
                l.GetProperty("rel").GetString() == "approve").GetProperty("href").GetString();

            // Save pending payment record
            var payment = new PaymentInsertRequest
            {
                ReservationId = request.ReservationId,
                UserId = request.UserId,
                Amount = request.Amount,
                PayPalOrderId = orderId,
                Status = "PENDING"
            };

            await Insert(payment);

            return new PayPalOrderResponse
            {
                OrderId = orderId,
                ApprovalUrl = approvalUrl,
                Status = "CREATED"
            };
        }

        public async Task<PayPalCaptureResponse> CapturePayPalOrder(CapturePayPalOrderRequest request)
        {
            var accessToken = await GetPayPalAccessToken();

            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {accessToken}");

            var content = new StringContent("{}", Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync($"{_paypalBaseUrl}/v2/checkout/orders/{request.OrderId}/capture", content);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"PayPal Capture Error: {responseContent}");
            }

            var captureResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
            var status = captureResponse.GetProperty("status").GetString();

            if (status == "COMPLETED")
            {
                var purchaseUnits = captureResponse.GetProperty("purchase_units").EnumerateArray().First();
                var payments = purchaseUnits.GetProperty("payments");
                var captures = payments.GetProperty("captures").EnumerateArray().First();
                var captureId = captures.GetProperty("id").GetString();
                var amount = decimal.Parse(captures.GetProperty("amount").GetProperty("value").GetString());

                // Update payment record
                var existingPayment = await _context.Payments
                    .FirstOrDefaultAsync(p => p.PayPalOrderId == request.OrderId);

                if (existingPayment != null)
                {
                    existingPayment.PayPalPaymentId = captureId;
                    existingPayment.Status = "COMPLETED";
                    existingPayment.TransactionDate = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                }

                return new PayPalCaptureResponse
                {
                    PaymentId = captureId,
                    Status = "COMPLETED",
                    Amount = amount,
                    TransactionDate = DateTime.UtcNow
                };
            }
            else
            {
                throw new Exception($"Payment capture failed with status: {status}");
            }
        }

        public async Task<List<PaymentModel>> GetPaymentsByReservationId(int reservationId)
        {
            var payments = await _context.Payments
                .Where(p => p.ReservationId == reservationId)
                .ToListAsync();

            return Mapper.Map<List<PaymentModel>>(payments);
        }

        private async Task<string> GetPayPalAccessToken()
        {
            var authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_clientId}:{_clientSecret}"));

            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Basic {authString}");

            var requestBody = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/x-www-form-urlencoded");

            var response = await _httpClient.PostAsync($"{_paypalBaseUrl}/v1/oauth2/token", requestBody);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"Failed to get PayPal access token: {responseContent}");
            }

            var tokenResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
            return tokenResponse.GetProperty("access_token").GetString();
        }

        public override void beforeInsert(PaymentInsertRequest request, Payment entity)
        {
            entity.TransactionDate = DateTime.UtcNow;
            if (string.IsNullOrEmpty(entity.Status))
            {
                entity.Status = "PENDING";
            }
        }
    }
}
