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

        private readonly IImageService _imageService;

        public ParcelController(IParcelService service, IImageService imageService)
        : base(service)
        {
            _imageService = imageService;
        }

        [AllowAnonymous]
        public override PagedResult<ParcelModel> GetList([FromQuery] ParcelSearchObject searchObject)
        {
            var result = base.GetList(searchObject);

            // If images aren't already loaded by the service, add them here
            if (result?.ResultList != null)
            {
                foreach (var parcel in result.ResultList)
                {
                    if (parcel.Images == null || parcel.Images.Count == 0)
                    {
                        parcel.Images = _imageService.GetByParcelId(parcel.ParcelId);
                    }
                }
            }

            return result;
        }

        [Authorize(Roles = "Admin")]
        public override ParcelModel GetById(int id)
        {
            var parcel = base.GetById(id);

            // If images aren't already loaded by the service, add them here
            if (parcel != null && (parcel.Images == null || parcel.Images.Count == 0))
            {
                parcel.Images = _imageService.GetByParcelId(id);
            }

            return parcel;
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
