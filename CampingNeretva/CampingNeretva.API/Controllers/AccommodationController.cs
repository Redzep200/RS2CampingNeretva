using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Service.ImageServices;
using Microsoft.AspNetCore.Mvc.ActionConstraints;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccommodationController : BaseCRUDController<AccommodationModel, AccommodationSearchObject, AcommodationInsertRequest, AcommodationUpdateRequest>
    {
        private readonly AccommodationImageService _imageService;

        public AccommodationController(IAccommodationService service, AccommodationImageService imageService)
        :base(service){
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override PagedResult<AccommodationModel> GetList([FromQuery] AccommodationSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel Insert(AcommodationInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel Update(int id, AcommodationUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [HttpPost("{accommodationId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int accommodationId, int imageId)
        {
            await _imageService.AddImage(accommodationId, imageId);
            return Ok();
        }

        [HttpDelete("{accommodationId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int accommodationId, int imageId)
        {
            await _imageService.RemoveImage(accommodationId, imageId);
            return Ok();
        }
    }
}
