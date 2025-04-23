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

        [AllowAnonymous]
        public override PagedResult<ReservationModel> GetList([FromQuery] ReservationSearchObject search)
        {
            return base.GetList(search);
        }

        [Authorize(Roles = "Admin")]
        public override ReservationModel Insert([FromBody] ReservationInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override ReservationModel Update(int id, [FromBody] ReservationUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override ReservationModel GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
