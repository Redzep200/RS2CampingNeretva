using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class FacilityService : IFacilityService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public FacilityService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<FacilityModel> GetList(FacilitySearchObject searchObject)
        {
            List<FacilityModel> result = new List<FacilityModel>();

            var query = _context.Facilities.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.FacilityTypeGTE))
            {
                query = query.Where(x => x.FacilityType.StartsWith(searchObject.FacilityTypeGTE));
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
