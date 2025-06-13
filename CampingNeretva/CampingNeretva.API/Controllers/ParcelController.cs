using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Service.ImageServices;
using CampingNeretva.Model.DTO;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ParcelController : BaseCRUDController<ParcelModel, ParcelSearchObject, ParcelInsertRequest, ParcelUpdateRequest>
    {
        private readonly ParcelImageService _imageService;
        private readonly ParcelService _parcelService;

        public ParcelController(IParcelService service, ParcelImageService imageService, ParcelService parcelService)
        : base(service)
        {
            _imageService = imageService;
            _parcelService = parcelService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<ParcelModel>> GetList([FromQuery] ParcelSearchObject searchObject)
        {
            var result = await base.GetList(searchObject);

            return result;
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


        [HttpGet("unavailable")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<List<UnavailableParcelModel>>> GetUnavailableParcels([FromQuery] DateTime dateFrom, [FromQuery] DateTime dateTo)
        {
            var result = await _parcelService.GetUnavailableParcels(dateFrom, dateTo);
            return Ok(result);
        }
    }
}
