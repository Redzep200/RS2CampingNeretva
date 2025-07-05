using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : BaseCRUDController<RoleModel, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
        public RoleController(IRoleService service)
        :base(service){
        }
    }
}
