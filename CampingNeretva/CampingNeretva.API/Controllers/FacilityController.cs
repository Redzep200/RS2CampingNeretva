using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using System.Dynamic;
using CampingNeretva.Service.ImageServices;

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
        public override PagedResult<FacilityModel> GetList([FromQuery] FacilitySearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel Insert(FacilityInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel Update(int id, FacilityUpdateRequest request)
        {
            return base.Update(id, request);
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
