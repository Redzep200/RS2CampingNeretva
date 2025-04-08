using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserModel, UserSearchObject, UserInsertRequest, UserInsertRequest>
    {
        public UserController(IUserService service)
        :base(service){
        }
    }
}
