using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccommodationController : ControllerBase
    {
        protected IAccommodationService _service;

        public AccommodationController(IAccommodationService service)
        {
            _service = service;
        }
        [HttpGet]
        public List<AccommodationModel> GetList()
        {
            return _service.GetList();
        }
    }
}
