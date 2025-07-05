using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkerController : BaseCRUDController<WorkerModel, WorkerSearchObject, WorkerInsertRequest, WorkerUpdateRequest>
    {
        public WorkerController(IWorkerService service)
        :base(service){
        }

        [Authorize(Roles = "Guest,Admin")]
        public override async Task<PagedResult<WorkerModel>> GetList([FromQuery] WorkerSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

    }
}
