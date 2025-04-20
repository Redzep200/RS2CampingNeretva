using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service.ImageServices;

namespace CampingNeretva.Service
{
    public class FacilityService : BaseCRUDService<FacilityModel, FacilitySearchObject, Facility, FacilityInsertRequest, FacilityUpdateRequest>,IFacilityService
    {
        private readonly FacilityImageService _facilityImageService;
        public FacilityService(_200012Context context, IMapper mapper, FacilityImageService facilityImageService)
        :base(context, mapper){
            _facilityImageService = facilityImageService;
        }

        public override IQueryable<Facility> AddFilter(FacilitySearchObject search, IQueryable<Facility> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FacilityTypeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.FacilityType.StartsWith(search.FacilityTypeGTE));
            }

            return filteredQuery;
        }

        public override FacilityModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _facilityImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }

        public override PagedResult<FacilityModel> GetPaged(FacilitySearchObject search)
        {
            var result = base.GetPaged(search);

            foreach (var facility in result.ResultList)
            {
                facility.Images = _facilityImageService.GetImages(facility.FacilityId).GetAwaiter().GetResult();
            }

            return result;
        }
    }
}
