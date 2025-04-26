using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    public class ParcelTypeController : BaseCRUDController<ParcelTypeModel, ParcelTypeSearchObject, ParcelTypeUpsertRequest, ParcelTypeUpsertRequest>
    {
        public ParcelTypeController(IParcelTypeService service) : base(service) { }
    }
}
