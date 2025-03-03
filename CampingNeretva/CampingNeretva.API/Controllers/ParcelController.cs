using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ParcelController : ControllerBase
    {
        protected IParcelService _service;

        public ParcelController(IParcelService service)
        {
            _service = service;
        }

        [HttpGet]
       public List<ParcelModel> getList()
        {
            return _service.GetList();
        }
    }
}
