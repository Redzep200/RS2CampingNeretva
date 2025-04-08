using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class VehicleController : BaseCRUDController<VehicleModel, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        public VehicleController(IVehicleService service)
        :base(service){
        }
    }
}
