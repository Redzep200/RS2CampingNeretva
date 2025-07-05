using Microsoft.AspNetCore.Mvc;
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
    public class VehicleController : BaseCRUDController<VehicleModel, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        private readonly VehicleImageService _imageService;
        public VehicleController(IVehicleService service, VehicleImageService imageService)
        :base(service){
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<VehicleModel>> GetList([FromQuery] VehicleSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }
        
        [HttpPost("{vehicleId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int vehicleId, int imageId)
        {
            await _imageService.AddImage(vehicleId, imageId);
            return Ok();
        }

        [HttpDelete("{vehicleId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int vehicleId, int imageId)
        {
            await _imageService.RemoveImage(vehicleId, imageId);
            return Ok();
        }
    }
}
