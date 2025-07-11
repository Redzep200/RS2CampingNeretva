﻿using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {

        protected ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;

        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
        }

        [HttpPost]
        public virtual async Task<TModel> Insert(TInsert request)
        {
            return await _service.Insert(request);
        }

        [HttpPut("{id}")]
        public virtual async Task<TModel> Update(int id, TUpdate request)
        {
            return await _service.Update(id, request);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            await _service.Delete(id);
            return Ok();
        }
    }
}
