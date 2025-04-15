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
    public class ParcelController : BaseCRUDController<ParcelModel, ParcelSearchObject, ParcelInsertRequest, ParcelUpdateRequest>
    {

        public ParcelController(IParcelService service)
        :base(service){
        }

        [AllowAnonymous]
        public override PagedResult<ParcelModel> GetList([FromQuery] ParcelSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel Insert(ParcelInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel Update(int id, ParcelUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
