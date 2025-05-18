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
    public class RentableItemController : BaseCRUDController<RentableItemModel, RentableItemSearchObject, RentableItemInsertRequest, RentableItemsUpdateRequest>
    {
        private readonly IRentableItemService _rentableItemService;
        private readonly RentableItemImageService _imageService;
        public RentableItemController(IRentableItemService service, RentableItemImageService imageService)
        : base(service)
        {
            _rentableItemService = service;
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<RentableItemModel>> GetList([FromQuery] RentableItemSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RentableItemModel> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RentableItemModel> Insert(RentableItemInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<RentableItemModel> Update(int id, RentableItemsUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpGet("available")]
        [AllowAnonymous]
        public async Task<IActionResult> GetAvailable([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        {
            if (from.HasValue && to.HasValue)
            {
                var result = await _rentableItemService.GetAvailableAsync(from.Value, to.Value);
                return Ok(result);
            }

            // No filter - return all rentable items with full availability
            var search = new RentableItemSearchObject();
            var resultPaged = await _rentableItemService.GetPaged(search);

            foreach (var item in resultPaged.ResultList)
            {
                item.AvailableQuantity = item.TotalQuantity;
            }

            return Ok(resultPaged.ResultList);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await base.Delete(id);
            return Ok();
        }

        [HttpPost("{rentableItemId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AddImage(int rentableItemId, int imageId)
        {
            await _imageService.AddImage(rentableItemId, imageId);
            return Ok();
        }

        [HttpDelete("{rentableItemId}/images/{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int rentableItemId, int imageId)
        {
            await _imageService.RemoveImage(rentableItemId, imageId);
            return Ok();
        }
    }
}
