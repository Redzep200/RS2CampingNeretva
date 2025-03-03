using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class ReviewService : IReviewService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public ReviewService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<ReviewModel> GetList()
        {
            List<ReviewModel> result = new List<ReviewModel>();

            var list = _context.Reviews
                .Include(a => a.Worker).Include(b=>b.User)
                .ToList();

            result = Mapper.Map(list, result);

            for (int i = 0; i < result.Count; i++)
            {
                result[i].Worker = list[i].Worker?.FirstName+' '+ list[i].Worker?.LastName;
                result[i].UserName = list[i].User?.UserName;
            }

            return result;
        }
    }
}
