using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using System.Dynamic;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FacilityController : BaseCRUDController<FacilityModel, FacilitySearchObject, FacilityInsertRequest, FacilityUpdateRequest>
    {
        public FacilityController(IFacilityService service)
        :base(service){
        }

        [AllowAnonymous]
        public override PagedResult<FacilityModel> GetList([FromQuery] FacilitySearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel Insert(FacilityInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override FacilityModel Update(int id, FacilityUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
