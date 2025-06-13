using CampingNeretva.Model;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class BaseController<TModel, TSearch> : ControllerBase where TSearch : BaseSearchObject
    {
        protected IService<TModel, TSearch> _service;
        public BaseController(IService<TModel, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual async Task<PagedResult<TModel>> GetList([FromQuery] TSearch searchObject)
        {
            return await _service.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        public virtual async Task<TModel> GetById(int id)
        {
            return await _service.GetById(id);
        }

    }
}
