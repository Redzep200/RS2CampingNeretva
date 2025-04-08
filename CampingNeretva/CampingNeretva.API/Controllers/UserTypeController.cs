using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
        [ApiController]
        [Route("[controller]")]
        public class UserTypeController : BaseCRUDController<UserTypeModel, UserTypeSearchObject, UserTypeUpsertRequest, UserTypeUpsertRequest>
        {

            public UserTypeController(IUserTypeService service)
            :base(service){
            }
        }
}
