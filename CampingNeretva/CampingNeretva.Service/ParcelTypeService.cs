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
    public class ParcelTypeService : BaseCRUDService<ParcelTypeModel, ParcelTypeSearchObject, ParcelType, ParcelTypeUpsertRequest, ParcelTypeUpsertRequest>, IParcelTypeService
    {
        public ParcelTypeService(_200012Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
