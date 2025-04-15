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
        public override PagedResult<UserTypeModel> GetList([FromQuery] UserTypeSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override UserTypeModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override UserTypeModel Insert(UserTypeUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override UserTypeModel Update(int id, UserTypeUpsertRequest request)
        {
            return base.Update(id, request);
        }
    }
}
