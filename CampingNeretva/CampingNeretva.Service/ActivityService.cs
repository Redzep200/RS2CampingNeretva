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
    public class ActivityService : IActivityService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public ActivityService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<ActivityModel> GetList(ActivitySearchObject searchObject)
        {
            List<ActivityModel> result = new List<ActivityModel>();

            var query = _context.Activities.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.NameGTE))
            {
                query = query.Where(x => x.Name.StartsWith(searchObject.NameGTE));
            }

            if (searchObject?.Price.HasValue == true)
            {
                query = query.Where(x => x.Price == searchObject.Price);
            }

            if (searchObject.IsFacilityTypeIncluded == true)
            {
                query = query.Include(x => x.Facility);
            }

            if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true)
            {
                query = query.Skip(searchObject.Page.Value * searchObject.PageSize.Value).Take(searchObject.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            return result;
        }
    }
}
