using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.Service
{
    public class AccommodationService : BaseService<AccommodationModel, AccommodationSearchObject, Accommodation>, IAccommodationService
    {

        public AccommodationService(CampingNeretvaRs2Context context, IMapper mapper)
        : base(context, mapper)
        {
        }

    }
}
