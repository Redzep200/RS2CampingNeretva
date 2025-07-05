using MapsterMapper;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.Service.Services
{
    public class RoleService : BaseCRUDService<RoleModel, RoleSearchObject, Role, RoleUpsertRequest, RoleUpsertRequest>, IRoleService
    {

        public RoleService(_200012Context context, IMapper mapper)
        : base(context, mapper)
        {
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

        public override async Task Delete(int id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null)
            {
                throw new Exception("Role not found");
            }

            var workersWithRole = await _context.Workers.Include(w => w.Roles)
                .Where(w => w.Roles.Any(r => r.RoleId == id)).ToListAsync();

            foreach (var worker in workersWithRole)
            {
                var roleToRemove = worker.Roles.First(r => r.RoleId == id);
                worker.Roles.Remove(roleToRemove);
            }

            _context.Roles.Remove(role);
            await _context.SaveChangesAsync();
        }
    }
}
