using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
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
    }
}
