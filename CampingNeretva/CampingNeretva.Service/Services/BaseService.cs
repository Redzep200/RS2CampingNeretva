using CampingNeretva.Model.Models;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using CampingNeretva.Service.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Services
{
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
    {
        public _200012Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public BaseService(_200012Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual async Task<PagedResult<TModel>> GetPaged(TSearch search)
        {
            var query = _context.Set<TDbEntity>().AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<TModel>>(list);

            return new PagedResult<TModel>
            {
                ResultList = result,
                Count = count
            };
        }


        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }

        public virtual async Task<TModel> GetById(int id)
        {
            var entity = await _context.Set<TDbEntity>().FindAsync(id);

            if (entity != null) { return Mapper.Map<TModel>(entity); }
            else { return null; }

        }
    }
}
