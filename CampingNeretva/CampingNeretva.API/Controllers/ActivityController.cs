using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActivityController : ControllerBase
    {
        protected IActivityService _service;
        public ActivityController(IActivityService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<ActivityModel> GetList()
        {
            return _service.GetList();
        }
    }
}
