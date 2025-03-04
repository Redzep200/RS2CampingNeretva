using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;

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

        public virtual List<ParcelModel> GetList(ParcelSearchObject searchObject)
        {
            List<ParcelModel> result = new List<ParcelModel>();

            var query = _context.Parcels.AsQueryable();

            if (searchObject?.ParcelNumber != null)
            {
                query = query.Where(x => x.ParcelNumber == searchObject.ParcelNumber);
            }

            if (searchObject?.Electricity == true || searchObject?.Electricity == false)
            {
                query = query.Where(x => x.Electricity == searchObject.Electricity);
            }

            if (searchObject?.Shade == true || searchObject?.Shade == false)
            {
                query = query.Where(x => x.Shade == searchObject.Shade);
            }

            if (searchObject?.AvailabilityStatus == true || searchObject?.AvailabilityStatus == false)
            {
                query = query.Where(x => x.AvailabilityStatus == searchObject.AvailabilityStatus);
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);
            return result;
        }
    }
}
