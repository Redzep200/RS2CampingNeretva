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
    public class WorkerService : BaseService<WorkerModel, WorkerSearchObject, Worker>, IWorkerService
    {

        public WorkerService(CampingNeretvaRs2Context context, IMapper mapper)
        :base(context, mapper){
        }
    }
}
