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
    public class UserController : BaseCRUDController<UserModel, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService service)
        :base(service){
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public UserModel Login([FromBody] LoginRequest request)
        {
            return (_service as IUserService).Login(request.Username, request.Password);
        }

        [AllowAnonymous]
        public override async Task<UserModel> Insert(UserInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Guest,Admin")]
        public override async Task<UserModel> Update(int id, UserUpdateRequest request)
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

        [HttpPut("me")]
        [AllowAnonymous]
        public async Task<UserModel> UpdateOwnProfile([FromBody] UserUpdateRequest request)
        {
            var username = User.Identity?.Name;
            return await (_service as IUserService).UpdateOwnProfile(username, request);
        }
    }
}
