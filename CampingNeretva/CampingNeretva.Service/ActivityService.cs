using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using System.Reflection.Metadata.Ecma335;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.Service
{
    public class ActivityService : BaseCRUDService<ActivityModel, ActivitySearchObject, Activity, ActivityInsertRequest, ActivityUpdateRequest>, IActivityService
    {
        public ActivityService(CampingNeretvaRs2Context context, IMapper mapper)
            :base(context, mapper){     
        }

        public override IQueryable<Activity> AddFilter(ActivitySearchObject search, IQueryable<Activity> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.StartsWith(search.NameGTE));
            }

            if(search?.Price.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.Price == search.Price);
            }

            if(search?.IsFacilityTypeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Facility);
            }

            return filteredQuery;
        }
    }
}
