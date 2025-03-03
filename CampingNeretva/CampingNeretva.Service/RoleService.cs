using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class RoleService : IRoleService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public RoleService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<RoleModel> GetList()
        {
            List<RoleModel> result = new List<RoleModel>();

            var list = _context.Roles.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
