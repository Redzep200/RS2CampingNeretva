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
    public class VehicleService : IVehicleService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public VehicleService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<VehicleModel> GetList()
        {
            List<VehicleModel> result = new List<VehicleModel>();

            var list = _context.Vehicles.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
