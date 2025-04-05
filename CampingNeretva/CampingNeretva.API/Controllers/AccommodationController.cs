using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccommodationController : BaseCRUDController<AccommodationModel, AccommodationSearchObject, AcommodationInsertRequest, AcommodationUpdateRequest>
    {
        public AccommodationController(IAccommodationService service)
        :base(service){
        }
    }
}
