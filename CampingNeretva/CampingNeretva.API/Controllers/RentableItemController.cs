using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Service;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RentableItemController : BaseController<RentableItemModel, RentableItemSearchObject>
    {

        public RentableItemController(IRentableItemService service)
        :base(service){
        }
    }
}
