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
    public class RentableItemController : BaseCRUDController<RentableItemModel, RentableItemSearchObject, RentableItemInsertRequest, RentableItemsUpdateRequest>
    {

        public RentableItemController(IRentableItemService service)
        :base(service){
        }

        [AllowAnonymous]
        public override PagedResult<RentableItemModel> GetList([FromQuery] RentableItemSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel Insert(RentableItemInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override RentableItemModel Update(int id, RentableItemsUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
