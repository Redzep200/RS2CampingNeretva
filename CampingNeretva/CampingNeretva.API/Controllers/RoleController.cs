using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : BaseCRUDController<RoleModel, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
        public RoleController(IRoleService service)
        :base(service){
        }

        [Authorize(Roles = "Admin")]
        public override async Task<PagedResult<RoleModel>> GetList([FromQuery] RoleSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RoleModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RoleModel> Insert(RoleUpsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RoleModel> Update(int id, RoleUpsertRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await base.Delete(id);
            return Ok();
        }
    }
}
