using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseController<UserModel, UserSearchObject>
    {
        public UserController(IUserService service)
        :base(service){
        }
    }
}
