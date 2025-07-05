using CampingNeretva.Model.SearchObjects;
using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using System.Dynamic;
using CampingNeretva.Service.ImageServices;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FacilityController : BaseCRUDController<FacilityModel, FacilitySearchObject, FacilityInsertRequest, FacilityUpdateRequest>
    {
        private readonly FacilityImageService _imageService;

        public FacilityController(IFacilityService service, FacilityImageService imageService)
        :base(service){
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<FacilityModel>> GetList([FromQuery] FacilitySearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }


        [HttpPost("{facilityId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int facilityId, int imageId)
        {
            await _imageService.AddImage(facilityId, imageId);
            return Ok();
        }

        [HttpDelete("{facilityId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int facilityId, int imageId)
        {
            await _imageService.RemoveImage(facilityId, imageId);
            return Ok();
        }
    }
}
