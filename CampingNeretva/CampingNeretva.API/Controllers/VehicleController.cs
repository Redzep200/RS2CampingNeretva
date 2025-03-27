using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class VehicleController : BaseController<VehicleModel, VehicleSearchObject>
    {
        public VehicleController(IVehicleService service)
        :base(service){
        }
    }
}
