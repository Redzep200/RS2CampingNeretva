using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReservationController : BaseCRUDController<ReservationModel, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        public ReservationController(IReservationService service)
            : base(service)
        {
        }

        [Authorize(Roles = "Guest,Admin")]
        public override async Task<PagedResult<ReservationModel>> GetList([FromQuery] ReservationSearchObject search)
        {
            return await base.GetList(search);
        }

        [Authorize(Roles = "Guest")]
        public override async Task<ReservationModel> Insert([FromBody] ReservationInsertRequest request)
        {
            return await base.Insert(request);
        }

        [Authorize(Roles = "Guest")]
        public override async Task<ReservationModel> Update(int id, [FromBody] ReservationUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Guest,Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await base.Delete(id);
            return Ok();
        }

    }
}
