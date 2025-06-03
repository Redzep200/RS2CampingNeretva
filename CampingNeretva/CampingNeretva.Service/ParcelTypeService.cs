using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class ParcelTypeService : BaseCRUDService<ParcelTypeModel, ParcelTypeSearchObject, ParcelType, ParcelTypeUpsertRequest, ParcelTypeUpsertRequest>, IParcelTypeService
    {
        public ParcelTypeService(_200012Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override async Task Delete(int id)
        {
            var type = await _context.ParcelTypes.FindAsync(id);
            if (type == null)
            {
                throw new Exception("Type not found");
            }
            var relatedParcels = await _context.Parcels
                                      .Where(x => x.ParcelTypeId == id)
                                      .ToListAsync();
            _context.Parcels.RemoveRange(relatedParcels);

            _context.ParcelTypes.Remove(type);
            await _context.SaveChangesAsync();
        }

    }
}
