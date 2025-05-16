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
        public override async Task<PagedResult<ParcelModel>> GetList([FromQuery] ParcelSearchObject searchObject)
        {
            var result = await base.GetList(searchObject);

            return result;
        }

        [Authorize(Roles = "Admin")]
        public override async Task<ParcelModel> GetById(int id)
        {
            var parcel =await base.GetById(id);

            return parcel;
        }

        [Authorize(Roles = "Admin")]
        public override async Task<ParcelModel> Insert(ParcelInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<ParcelModel> Update(int id, ParcelUpdateRequest request)
        {
            return await base.Update(id, request);
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
