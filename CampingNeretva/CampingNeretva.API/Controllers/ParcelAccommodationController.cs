using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ParcelAccommodationController : BaseCRUDController<ParcelAccommodationModel, ParcelAccommodationSearchObject, ParcelAccommodationUpsertRequest, ParcelAccommodationUpsertRequest>
    {
       public ParcelAccommodationController(IParcelAccommodationService service):base(service) { }
    }
}
