using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

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
        public List<WorkerModel> GetList()
        {
            return _service.GetList();
        }
    }
}
