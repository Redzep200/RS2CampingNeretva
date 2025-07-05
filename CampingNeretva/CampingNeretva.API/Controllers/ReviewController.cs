using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseCRUDController<ReviewModel, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {

        public ReviewController(IReviewService service)
        :base(service){
        }


        [Authorize(Roles = "Guest,Admin")]
        public override async Task<PagedResult<ReviewModel>> GetList([FromQuery] ReviewSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }


        [Authorize(Roles = "Guest")]
        public override async Task<ReviewModel> Insert(ReviewInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Guest")]
        public override async Task<ReviewModel> Update(int id, ReviewUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Guest,Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await base.Delete(id);
            return Ok();
        }
    }
}
