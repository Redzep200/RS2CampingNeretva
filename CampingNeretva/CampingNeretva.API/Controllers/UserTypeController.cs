using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;

namespace CampingNeretva.API.Controllers
{
        [ApiController]
        [Route("[controller]")]
        public class UserTypeController : ControllerBase
        {
            protected IUserTypeService _service;

            public UserTypeController(IUserTypeService service)
            {
                _service = service;
            }

            [HttpGet]
            public List<UserTypeModel> GetList()
            {
                return _service.GetList();
            }
        }
}
