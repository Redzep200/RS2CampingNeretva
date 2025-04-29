using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    public class ParcelTypeController : BaseCRUDController<ParcelTypeModel, ParcelTypeSearchObject, ParcelTypeUpsertRequest, ParcelTypeUpsertRequest>
    {
        public ParcelTypeController(IParcelTypeService service) : base(service) { }

        [AllowAnonymous]
        public override PagedResult<ParcelTypeModel> GetList([FromQuery] ParcelTypeSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }


    }
}
