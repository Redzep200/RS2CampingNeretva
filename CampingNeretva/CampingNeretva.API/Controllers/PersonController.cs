using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Service.ImageServices;

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

        [Authorize(Roles = "Admin")]
        public override async Task<PersonModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<PersonModel> Insert(PersonInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<PersonModel> Update(int id, PersonUpdateRequest request)
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
