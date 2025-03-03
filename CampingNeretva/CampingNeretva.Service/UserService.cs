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
    public class UserService : IUserService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public UserService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<UserModel> GetList()
        {
            List<UserModel> result = new List<UserModel>();

            var list = _context.Users.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
