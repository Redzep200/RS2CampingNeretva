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
using CampingNeretva.Service.ImageServices;

namespace CampingNeretva.Service
{
    public class ActivityService : BaseCRUDService<ActivityModel, ActivitySearchObject, Activity, ActivityInsertRequest, ActivityUpdateRequest>, IActivityService
    {
        private readonly ActivityImageService _activityImageService;

        public ActivityService(_200012Context context, IMapper mapper, ActivityImageService activityImageService)
            :base(context, mapper){     
            _activityImageService = activityImageService;
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

        public override ActivityModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _activityImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }

        public override PagedResult<ActivityModel> GetPaged(ActivitySearchObject search)
        {
            var result = base.GetPaged(search);

            foreach (var activity in result.ResultList)
            {
                activity.Images = _activityImageService.GetImages(activity.ActivityId).GetAwaiter().GetResult();
            }

            return result;
        }
    }
}
