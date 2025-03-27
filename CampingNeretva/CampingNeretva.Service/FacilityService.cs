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
    public class FacilityService : BaseService<FacilityModel, FacilitySearchObject, Facility>,IFacilityService
    {

        public FacilityService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
        }
    }
}
