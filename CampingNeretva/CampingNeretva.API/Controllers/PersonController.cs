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
    public class PersonController : BaseCRUDController<PersonModel, PersonSearchObject, PersonInsertRequest, PersonUpdateRequest>
    {
        public PersonController(IPersonService service)
        :base(service){ 
        }

        [AllowAnonymous]
        public override PagedResult<PersonModel> GetList([FromQuery] PersonSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel Insert(PersonInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override PersonModel Update(int id, PersonUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
