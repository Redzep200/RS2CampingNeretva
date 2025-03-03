using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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

        public List<WorkerModel> GetList()
        {
            List<WorkerModel> result = new List<WorkerModel>();
            var list = _context.Workers
                .Include(a => a.Roles)
                .ToList();
            result = Mapper.Map(list, result);
            for (int i = 0; i < result.Count; i++)
            {
                result[i].Roles = string.Join(", ", list[i].Roles.Select(r => r.RoleName));
            }
            return result;
        }
    }
}
