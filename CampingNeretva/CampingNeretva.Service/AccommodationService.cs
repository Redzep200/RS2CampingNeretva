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

        public override IQueryable<Accommodation> AddFilter(AccommodationSearchObject search, IQueryable<Accommodation> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Type.StartsWith(search.TypeGTE));
            }

            if (search?.PricePerNightGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.PricePerNight == search.PricePerNightGTE);
            }

            return filteredQuery;
        }

    }
}
