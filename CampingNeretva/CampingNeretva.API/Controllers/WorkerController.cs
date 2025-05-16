using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkerController : BaseCRUDController<WorkerModel, WorkerSearchObject, WorkerInsertRequest, WorkerUpdateRequest>
    {
        public WorkerController(IWorkerService service)
        :base(service){
        }

        [AllowAnonymous]
        public override async Task<PagedResult<WorkerModel>> GetList([FromQuery] WorkerSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<WorkerModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<WorkerModel> Insert(WorkerInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<WorkerModel> Update(int id, WorkerUpdateRequest request)
        {
            return await base.Update(id, request);
        }
    }
}
