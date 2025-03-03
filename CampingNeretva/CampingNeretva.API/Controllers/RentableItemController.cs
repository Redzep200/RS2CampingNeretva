using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RentableItemController : ControllerBase
    {
        protected IRentableItemService _service;

        public RentableItemController(IRentableItemService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<RentableItemModel> GetList()
        {
            return _service.GetList();
        }
    }
}
