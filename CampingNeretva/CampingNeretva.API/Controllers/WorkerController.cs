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
        public override PagedResult<WorkerModel> GetList([FromQuery] WorkerSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override WorkerModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override WorkerModel Insert(WorkerInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override WorkerModel Update(int id, WorkerUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
