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
    public class VehicleController : BaseCRUDController<VehicleModel, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        private readonly VehicleImageService _imageService;
        public VehicleController(IVehicleService service, VehicleImageService imageService)
        :base(service){
            _imageService = imageService;
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel Update(int id, VehicleUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [AllowAnonymous]
        public override PagedResult<VehicleModel> GetList([FromQuery] VehicleSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override VehicleModel Insert(VehicleInsertRequest request)
        {
            return base.Insert(request);
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
