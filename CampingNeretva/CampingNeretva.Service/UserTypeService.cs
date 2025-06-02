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
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service
{
    public class UserTypeService : BaseCRUDService<UserTypeModel, UserTypeSearchObject, UserType, UserTypeUpsertRequest, UserTypeUpsertRequest>, IUserTypeService
    {
        public UserTypeService(_200012Context context, IMapper mapper)
        :base(context, mapper){
        }

        public override IQueryable<UserType> AddFilter(UserTypeSearchObject search, IQueryable<UserType> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.TypeName.StartsWith(search.TypeNameGTE));
            }
            
            return filteredQuery;
        }


        public override async Task Delete(int id)
        {
            var type = await _context.UserTypes.FindAsync(id);
            if (type == null)
            {
                throw new Exception("User type not found");
            }

            var relatedUsers = await _context.Users.Where(x => x.UserTypeId == id).ToListAsync();
            _context.Users.RemoveRange(relatedUsers);

            _context.UserTypes.Remove(type);
            await _context.SaveChangesAsync();
        }
    }
}
