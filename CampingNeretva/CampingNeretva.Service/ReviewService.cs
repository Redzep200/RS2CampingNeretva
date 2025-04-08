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
using CampingNeretva.Model.Requests;

namespace CampingNeretva.Service
{
    public class ReviewService : BaseCRUDService<ReviewModel, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
        }

        public override IQueryable<Review> AddFilter(ReviewSearchObject search, IQueryable<Review> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search?.WorkerIdGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.WorkerId == search.WorkerIdGTE);
            }

            if (search?.DatePostedGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.DatePosted == search.DatePostedGTE);
            }

            if (search?.IsUserIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.User);
            }

            if (search?.IsWorkerIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Worker);
            }

            return filteredQuery;
        }

        public override void beforeInsert(ReviewInsertRequest request, Review entity)
        {
            entity.DatePosted = DateTime.Now;
            var user = _context.Users.FirstOrDefault(x=>x.UserId == entity.UserId);
            if (user != null)
            {
                entity.User = user;
            }

            var worker = _context.Workers.FirstOrDefault(x=>x.WorkerId == entity.WorkerId);
            if(worker != null)
            {
                entity.Worker = worker;
            }
        }

    }
}
