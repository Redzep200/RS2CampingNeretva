using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseController<ReviewModel, ReviewSearchObject>
    {

        public ReviewController(IReviewService service)
        :base(service){
        }

    }
}
