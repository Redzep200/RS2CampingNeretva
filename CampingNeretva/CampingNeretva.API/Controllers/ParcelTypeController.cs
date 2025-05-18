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
        public override async Task<PagedResult<ParcelTypeModel>> GetList([FromQuery] ParcelTypeSearchObject searchObject)
        {
            return await base.GetList(searchObject);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await base.Delete(id);
            return Ok();
        }
    }
}
