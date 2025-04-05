using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PersonController : BaseCRUDController<PersonModel, PersonSearchObject, PersonInsertRequest, PersonUpdateRequest>
    {
        public PersonController(IPersonService service)
        :base(service){ 
        }
    }
}
