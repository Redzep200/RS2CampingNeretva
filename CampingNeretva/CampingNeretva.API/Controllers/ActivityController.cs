using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActivityController : BaseController<ActivityModel, ActivitySearchObject>
    {
        public ActivityController(IActivityService service)
        :base(service) { }
    }
}
