using MapsterMapper;
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
    public class RoleService : BaseService<RoleModel, RoleSearchObject, Role>, IRoleService
    {

        public RoleService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
        }
    }
}
