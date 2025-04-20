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
    public class ParcelController : BaseCRUDController<ParcelModel, ParcelSearchObject, ParcelInsertRequest, ParcelUpdateRequest>
    {
        private readonly ParcelImageService _imageService;

        public ParcelController(IParcelService service, ParcelImageService imageService)
        : base(service)
        {
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override PagedResult<ParcelModel> GetList([FromQuery] ParcelSearchObject searchObject)
        {
            var result = base.GetList(searchObject);

            return result;
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel GetById(int id)
        {
            var parcel = base.GetById(id);

            return parcel;
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel Insert(ParcelInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel Update(int id, ParcelUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [HttpPost("{parcelId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int parcelId, int imageId)
        {
            await _imageService.AddImage(parcelId, imageId);
            return Ok();
        }

        [HttpDelete("{parcelId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int parcelId, int imageId)
        {
            await _imageService.RemoveImage(parcelId, imageId);
            return Ok();
        }
    }
}
