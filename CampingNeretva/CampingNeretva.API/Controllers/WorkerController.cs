using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkerController : ControllerBase
    {
        protected IWorkerService _service;
        public WorkerController(IWorkerService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<WorkerModel> GetList([FromQuery]WorkerSearchObject searchObject)
        {
            return _service.GetList(searchObject);
        }
    }
}
