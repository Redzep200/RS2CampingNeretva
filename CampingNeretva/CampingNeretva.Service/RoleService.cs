using MapsterMapper;
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
    public class RoleService : BaseCRUDService<RoleModel, RoleSearchObject, Role, RoleUpsertRequest, RoleUpsertRequest>, IRoleService
    {

        public RoleService(_200012Context context, IMapper mapper)
        :base(context, mapper){
        }

        public override IQueryable<Role> AddFilter(RoleSearchObject search, IQueryable<Role> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.RoleNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.RoleName.StartsWith(search.RoleNameGTE));
            }

            return filteredQuery;
        }
    }
}
