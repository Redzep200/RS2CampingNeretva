using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.Service
{
    public class WorkerService : BaseCRUDService<WorkerModel, WorkerSearchObject, Worker, WorkerInsertRequest, WorkerUpdateRequest>, IWorkerService
    {

        public WorkerService(_200012Context context, IMapper mapper)
        : base(context, mapper)
        {
        }

        public override IQueryable<Worker> AddFilter(WorkerSearchObject search, IQueryable<Worker> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FirstNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.StartsWith(search.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(search.LastNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.LastName.StartsWith(search.LastNameGTE));
            }

            if (search?.IsWorkerRoleIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Roles);
            }

            return filteredQuery;

        }

        public override void beforeInsert(WorkerInsertRequest request, Worker entity)
        {
            if (request.Roles != null && request.Roles.Length > 0)
            {
                entity.Roles = new List<Role>();
                foreach (var roleId in request.Roles)
                {
                    var role = _context.Roles.Find(roleId);
                    if (role != null)
                    {
                        entity.Roles.Add(role);
                    }
                }
            }
        }

        public override async Task Delete(int id)
        {
            var worker = await _context.Workers.FindAsync(id);
            if (worker == null)
            {
                throw new Exception("Worker not found");
            }

            var relatedReviews = await _context.Reviews.Where(x => x.WorkerId == id).ToListAsync();
            _context.Reviews.RemoveRange(relatedReviews);

            _context.Entry(worker).Collection(w => w.Roles).Load();
            worker.Roles.Clear();

            _context.Workers.Remove(worker);
            await _context.SaveChangesAsync();
        }

        public override async void beforeUpdate(WorkerUpdateRequest request, Worker entity)
        {
            // Load current roles to make sure EF is tracking them
            // Load the current roles so EF tracks them
            _context.Entry(entity).Collection(w => w.Roles).Load();

            // Clear the current roles
            entity.Roles.Clear();

            // Fetch only the needed roles from the DB — they will be tracked and have RoleName
            var roles = _context.Roles
                .Where(r => request.Roles.Contains(r.RoleId))
                .ToList();

            // Assign them — no attaching, no new objects, no inserts
            foreach (var role in roles)
            {
                entity.Roles.Add(role);
            }
        }

        public override async Task<WorkerModel> Update(int id, WorkerUpdateRequest request)
        {
            var entity = await _context.Workers.Include(w => w.Roles).FirstOrDefaultAsync(w => w.WorkerId == id);
            if (entity == null)
                throw new Exception("Worker not found");

            // Only map fields we want
            entity.PhoneNumber = request.PhoneNumber;
            entity.Email = request.Email;

            // Manually assign roles properly
            _context.Entry(entity).Collection(w => w.Roles).Load();
            entity.Roles.Clear();

            var roles = _context.Roles.Where(r => request.Roles.Contains(r.RoleId)).ToList();
            foreach (var role in roles)
            {
                entity.Roles.Add(role);
            }

            await _context.SaveChangesAsync();
            return Mapper.Map<WorkerModel>(entity);
        }
    }
}
