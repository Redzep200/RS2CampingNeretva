using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PersonController : BaseController<PersonModel, PersonSearchObject>
    {
        public PersonController(IPersonService service)
        :base(service){ 
        }
    }
}
