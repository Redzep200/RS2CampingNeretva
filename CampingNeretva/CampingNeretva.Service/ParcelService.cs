using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class ParcelService : IParcelService
    {

        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public ParcelService(CampingNeretvaRs2Context context, IMapper mapper) {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<ParcelModel> GetList()
        {
            List<ParcelModel> result = new List<ParcelModel>();

            var list = _context.Parcels.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
