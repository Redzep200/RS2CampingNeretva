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
    public class ActivityController : BaseCRUDController<ActivityModel, ActivitySearchObject, ActivityInsertRequest, ActivityUpdateRequest>
    {
        public ActivityController(IActivityService service)
        :base(service) { }

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
    }
}
