using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccommodationController : BaseController<AccommodationModel, AccommodationSearchObject>
    {
        public AccommodationController(IAccommodationService service)
        :base(service){
        }
    }
}
