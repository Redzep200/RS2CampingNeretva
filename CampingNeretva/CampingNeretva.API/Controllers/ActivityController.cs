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
    public class ActivityController : BaseCRUDController<ActivityModel, ActivitySearchObject, ActivityInsertRequest, ActivityUpdateRequest>
    {
        private readonly ActivityImageService _imageService;

        public ActivityController(IActivityService service, ActivityImageService imageService)
        :base(service) {
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override PagedResult<ActivityModel> GetList([FromQuery] ActivitySearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override ActivityModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override ActivityModel Insert(ActivityInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override ActivityModel Update(int id, ActivityUpdateRequest request)
        {
            return base.Update(id, request);
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
