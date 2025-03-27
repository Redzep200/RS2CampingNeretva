using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkerController : BaseController<WorkerModel, WorkerSearchObject>
    {
        public WorkerController(IWorkerService service)
        :base(service){
        }
    }
}
