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

            if (search?.DateFrom.HasValue == true && search?.DateTo.HasValue == true)
            {
                query = query.Where(x =>
                    x.Date >= search.DateFrom.Value &&
                    x.Date <= search.DateTo.Value);
            }

            return filteredQuery;
        }

        public override async Task<ActivityModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _activityImageService.GetImages(id);
            }

            return model;
        }

        public override async Task<PagedResult<ActivityModel>> GetPaged(ActivitySearchObject search)
        {
            var result =await base.GetPaged(search);

            foreach (var activity in result.ResultList)
            {
                activity.Images =await _activityImageService.GetImages(activity.ActivityId);
            }

            return result;
        }

        public override async Task Delete(int id)
        {
            var activity = await _context.Activities.Include(a => a.Reservations).FirstOrDefaultAsync(a=>a.ActivityId == id);
            if (activity == null)
            {
                throw new Exception("Activity not found");
            }

            foreach (var reservation in activity.Reservations.ToList())
            {
                reservation.Activities.Remove(activity);
            }

            var activityImages = await _context.ActivityImages.Where(x => x.ActivityId == id).ToListAsync();
            _context.ActivityImages.RemoveRange(activityImages);

            var relatedRecommendations = await _context.UserRecommendations.Where(x=>x.ActivityId1 == id || x.ActivityId2 == id).ToListAsync();
            _context.UserRecommendations.RemoveRange(relatedRecommendations);

            _context.Activities.Remove(activity);
            await _context.SaveChangesAsync();
        }

        public override async Task<ActivityModel> Insert(ActivityInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.ActivityImages.Add(new ActivityImage
            {
                ActivityId = entity.ActivityId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.ActivityId);
        }

        public override async Task<ActivityModel> Update(int id, ActivityUpdateRequest request)
        {
            var entity = await base.Update(id, request);


            if (request.ImageId.HasValue && request.ImageId.Value > 0)
            {
                var existingLinks = await _context.ActivityImages.Where(x => x.ActivityId == id).ToListAsync();
            _context.ActivityImages.RemoveRange(existingLinks);

                _context.ActivityImages.Add(new ActivityImage
                {
                    ActivityId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }
}
