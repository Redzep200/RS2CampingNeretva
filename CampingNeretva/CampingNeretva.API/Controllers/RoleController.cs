using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : BaseController<RoleModel, RoleSearchObject>
    {
        public RoleController(IRoleService service)
        :base(service){
        }
    }
}
