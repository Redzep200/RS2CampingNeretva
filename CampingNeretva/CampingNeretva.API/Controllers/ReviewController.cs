using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : ControllerBase
    {
        protected IReviewService _service;

        public ReviewController(IReviewService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<ReviewModel> GetList()
        {
            return _service.GetList();
        }
    }
}
