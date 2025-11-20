using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using CampingNeretva.Service.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service.Services
{
    public class ActivityCommentService :
        BaseCRUDService<
            ActivityCommentModel,
            ActivityCommentSearchObject,
            ActivityComment,
            ActivityCommentInsertRequest,
            ActivityCommentUpdateRequest>,
        IActivityCommentService
    {
        public ActivityCommentService(_200012Context context, IMapper mapper)
            : base(context, mapper) { }

        public override IQueryable<ActivityComment> AddFilter(ActivityCommentSearchObject search, IQueryable<ActivityComment> query)
        {
            if (search == null)
                return query;

            if (search.ActivityId.HasValue)
                query = query.Where(x => x.ActivityId == search.ActivityId);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId);

            if (search.Rating.HasValue)
                query = query.Where(x => x.Rating == search.Rating);

            return query;
        }

        public override void beforeInsert(ActivityCommentInsertRequest request, ActivityComment entity)
        {
            entity.DatePosted = DateTime.Now;
        }
    }
}
