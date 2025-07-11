﻿using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Service.ImageServices;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PersonController : BaseCRUDController<PersonModel, PersonSearchObject, PersonInsertRequest, PersonUpdateRequest>
    {
        private readonly PersonImageService _imageService;
        public PersonController(IPersonService service, PersonImageService imageService)
        :base(service){ 
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<PersonModel>> GetList([FromQuery] PersonSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

       
        [HttpPost("{personId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int personId, int imageId)
        {
            await _imageService.AddImage(personId, imageId);
            return Ok();
        }

        [HttpDelete("{personId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int personId, int imageId)
        {
            await _imageService.RemoveImage(personId, imageId);
            return Ok();
        }
    }
}
