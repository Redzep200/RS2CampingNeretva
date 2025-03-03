using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PersonController : ControllerBase
    {
        protected IPersonService _service;

        public PersonController(IPersonService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<PersonModel> GetList()
        {
            return _service.GetList();
        }
    }
}
