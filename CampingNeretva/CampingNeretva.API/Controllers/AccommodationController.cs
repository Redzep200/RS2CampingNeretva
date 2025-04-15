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
    public class AccommodationController : BaseCRUDController<AccommodationModel, AccommodationSearchObject, AcommodationInsertRequest, AcommodationUpdateRequest>
    {
        public AccommodationController(IAccommodationService service)
        :base(service){
        }

        [AllowAnonymous]
        public override PagedResult<AccommodationModel> GetList([FromQuery] AccommodationSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel Insert(AcommodationInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override AccommodationModel Update(int id, AcommodationUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
