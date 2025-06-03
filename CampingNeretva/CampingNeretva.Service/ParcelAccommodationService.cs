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
    public class ParcelAccommodationService : BaseCRUDService<ParcelAccommodationModel, ParcelAccommodationSearchObject, ParcelAccommodation, ParcelAccommodationUpsertRequest, ParcelAccommodationUpsertRequest>, IParcelAccommodationService
    {
        public ParcelAccommodationService(_200012Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task Delete(int id)
        {
            var accommodation = await _context.ParcelAccommodations.FindAsync(id);
            if (accommodation == null)
            {
                throw new Exception("Accommodation not found");
            }
            var relatedParcels = await _context.Parcels
                                      .Where(x => x.ParcelAccommodationId == id)
                                      .ToListAsync();
            _context.Parcels.RemoveRange(relatedParcels);

            _context.ParcelAccommodations.Remove(accommodation);
            await _context.SaveChangesAsync();
        }
    }
}
