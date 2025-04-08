using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseCRUDController<ReviewModel, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {

        public ReviewController(IReviewService service)
        :base(service){
        }

    }
}
