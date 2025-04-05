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

namespace CampingNeretva.Service
{
    public class FacilityService : BaseCRUDService<FacilityModel, FacilitySearchObject, Facility, FacilityInsertRequest, FacilityUpdateRequest>,IFacilityService
    {

        public FacilityService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
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

    }
}
