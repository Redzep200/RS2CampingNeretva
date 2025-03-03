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
    public class UserTypeService : IUserTypeService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public UserTypeService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<UserTypeModel> GetList()
        {
            List<UserTypeModel> result = new List<UserTypeModel>();

            var list = _context.UserTypes.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
