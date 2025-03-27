using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ParcelController : BaseController<ParcelModel, ParcelSearchObject>
    {

        public ParcelController(IParcelService service)
        :base(service){
        }

    }
}
