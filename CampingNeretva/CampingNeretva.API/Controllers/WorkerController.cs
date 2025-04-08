using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkerController : BaseCRUDController<WorkerModel, WorkerSearchObject, WorkerInsertRequest, WorkerUpdateRequest>
    {
        public WorkerController(IWorkerService service)
        :base(service){
        }
    }
}
