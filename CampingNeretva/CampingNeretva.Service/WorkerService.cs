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

namespace CampingNeretva.Service
{
    public class WorkerService : IWorkerService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public WorkerService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<WorkerModel> GetList(WorkerSearchObject searchObject)
        {
            List<WorkerModel> result = new List<WorkerModel>();

            var query = _context.Workers.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
            {
                query = query.Where(x => x.FirstName.StartsWith(searchObject.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
            {
                query = query.Where(x => x.LastName.StartsWith(searchObject.LastNameGTE));
            }

            if (searchObject.IsWorkerRoleIncluded == true)
            {
                query = query.Include(x=>x.Roles);
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
