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
    public class ActivityController : BaseCRUDController<ActivityModel, ActivitySearchObject, ActivityInsertRequest, ActivityUpdateRequest>
    {
        private readonly ActivityImageService _imageService;

        public ActivityController(IActivityService service, ActivityImageService imageService)
        :base(service) {
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<ActivityModel>> GetList([FromQuery] ActivitySearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

       

        [HttpPost("{activityId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int activityId, int imageId)
        {
            await _imageService.AddImage(activityId, imageId);
            return Ok();
        }

        [HttpDelete("{activityId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int activityId, int imageId)
        {
            await _imageService.RemoveImage(activityId, imageId);
            return Ok();
        }
    }
}
