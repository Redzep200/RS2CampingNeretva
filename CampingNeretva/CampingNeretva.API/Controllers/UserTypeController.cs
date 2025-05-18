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
        public class UserTypeController : BaseCRUDController<UserTypeModel, UserTypeSearchObject, UserTypeUpsertRequest, UserTypeUpsertRequest>
        {

            public UserTypeController(IUserTypeService service)
            :base(service){
            }

        [Authorize(Roles = "Admin")]
        public override async Task<PagedResult<UserTypeModel>> GetList([FromQuery] UserTypeSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<UserTypeModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<UserTypeModel> Insert(UserTypeUpsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<UserTypeModel> Update(int id, UserTypeUpsertRequest request)
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
