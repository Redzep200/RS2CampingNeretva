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
    public class UserService : IUserService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public UserService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<UserModel> GetList(UserSearchObject searchObject)
        {
            List<UserModel> result = new List<UserModel>();

            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
            {
                query = query.Where(x => x.FirstName.StartsWith(searchObject.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
            {
                query = query.Where(x => x.LastName.StartsWith(searchObject.LastNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.UserName))
            {
                query = query.Where(x => x.UserName == searchObject.UserName);
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.Email))
            {
                query = query.Where(x => x.Email == searchObject.Email);
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
