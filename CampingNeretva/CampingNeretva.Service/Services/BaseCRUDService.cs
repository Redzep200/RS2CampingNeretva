using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
    {
        public BaseCRUDService(_200012Context context, IMapper mapper) : base(context, mapper) { }

        public virtual async Task<TModel> Insert(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            beforeInsert(request, entity);
            _context.Add(entity);
            await _context.SaveChangesAsync();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void beforeInsert(TInsert request, TDbEntity entity) { }

        public virtual async Task<TModel> Update(int id, TUpdate request)
        {
            var set = _context.Set<TDbEntity>();

            var entity = await set.FindAsync(id);
            if (entity == null)
            {
                throw new Exception("Entity not found");
            }

            Mapper.Map(request, entity);

            beforeUpdate(request, entity);

            await _context.SaveChangesAsync();
            return Mapper.Map<TModel>(entity);
        }

        public virtual void beforeUpdate(TUpdate request, TDbEntity entity) { }

        public virtual async Task Delete(int id)
        {
            var set = _context.Set<TDbEntity>();
            var entity = await set.FindAsync(id);

            if (entity == null)
                throw new Exception("Entity not found");

            set.Remove(entity);
            await _context.SaveChangesAsync();
        }
    }

}
