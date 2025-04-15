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
    public class VehicleController : BaseCRUDController<VehicleModel, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        public VehicleController(IVehicleService service)
        :base(service){
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel Update(int id, VehicleUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [AllowAnonymous]
        public override PagedResult<VehicleModel> GetList([FromQuery] VehicleSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel Insert(VehicleInsertRequest request)
        {
            return base.Insert(request);
        }
    }
}
