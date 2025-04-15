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
    public class UserController : BaseCRUDController<UserModel, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService service)
        :base(service){
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public UserModel Login(string username, string password)
        {
            return (_service as IUserService).Login(username, password);
        }

        [Authorize(Roles = "Admin")]
        public override PagedResult<UserModel> GetList([FromQuery] UserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override UserModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override UserModel Insert(UserInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override UserModel Update(int id, UserUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
