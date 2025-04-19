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
        public override PagedResult<PersonModel> GetList([FromQuery] PersonSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel Insert(PersonInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel Update(int id, PersonUpdateRequest request)
        {
            return base.Update(id, request);
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
