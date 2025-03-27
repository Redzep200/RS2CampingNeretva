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

namespace CampingNeretva.Service
{
    public class ReviewService : BaseService<ReviewModel, ReviewSearchObject, Review>, IReviewService
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

            return filteredQuery;
        }

    }
}
