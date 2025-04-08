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

        public WorkerService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
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
            if(request.Roles != null && request.Roles.Length > 0)
            {
                entity.Roles = new List<Role>();
                foreach ( var roleId in request.Roles)
                {
                    var role = _context.Roles.Find(roleId);
                    if (role != null)
                    {
                        entity.Roles.Add(role);
                    }
                }
            }
        }

    }
}
