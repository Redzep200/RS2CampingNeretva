using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
        [ApiController]
        [Route("[controller]")]
        public class UserTypeController : BaseController<UserTypeModel, UserTypeSearchObject>
        {

            public UserTypeController(IUserTypeService service)
            :base(service){
            }
        }
}
