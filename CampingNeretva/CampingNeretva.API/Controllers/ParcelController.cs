using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

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
       public List<ParcelModel> getList([FromQuery] ParcelSearchObject searchObject)
        {
            return _service.GetList(searchObject);
        }
    }
}
