using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseCRUDController<ReviewModel, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {

        public ReviewController(IReviewService service)
        :base(service){
        }


        [AllowAnonymous]
        public override PagedResult<ReviewModel> GetList([FromQuery] ReviewSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override ReviewModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Guest")]
        public override ReviewModel Insert(ReviewInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Guest")]
        public override ReviewModel Update(int id, ReviewUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
