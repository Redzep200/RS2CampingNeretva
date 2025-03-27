using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FacilityController : BaseController<FacilityModel, FacilitySearchObject>
    {
        public FacilityController(IFacilityService service)
        :base(service){
        }

    }
}
