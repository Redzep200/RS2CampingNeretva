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
        public override PagedResult<RentableItemModel> GetList([FromQuery] RentableItemSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel Insert(RentableItemInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel Update(int id, RentableItemsUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [HttpGet("available")]
        [AllowAnonymous]
        public IActionResult GetAvailable([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        {
            if (from.HasValue && to.HasValue)
            {
                var result = _rentableItemService.GetAvailable(from.Value, to.Value);
                return Ok(result);
            }

            // No filter - return all rentable items with full availability
            var search = new RentableItemSearchObject();
            var items = _rentableItemService.GetPaged(search).ResultList;

            foreach (var item in items)
            {
                item.AvailableQuantity = item.TotalQuantity;
            }

            return Ok(items);
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
