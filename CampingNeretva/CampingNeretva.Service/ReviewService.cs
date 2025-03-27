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
    }
}
