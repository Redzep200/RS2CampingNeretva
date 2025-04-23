using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
    {
        public BaseCRUDService(_200012Context context, IMapper mapper) : base(context, mapper) { }

        public virtual TModel Insert(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            beforeInsert(request, entity);
            _context.Add(entity);
            _context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void beforeInsert(TInsert request, TDbEntity entity) { }
                
        public TModel Update(int id, TUpdate request)
        {
            var set = _context.Set<TDbEntity>();

            var entity = set.Find(id);

            Mapper.Map(request, entity);

            beforeUpdate(request, entity);

            _context.SaveChanges();
            return Mapper.Map<TModel>(entity);
        }

        public virtual void beforeUpdate(TUpdate request, TDbEntity entity) { }
    }

}
