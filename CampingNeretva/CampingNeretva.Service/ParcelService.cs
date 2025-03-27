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
    public class ParcelService : BaseService<ParcelModel, ParcelSearchObject, Parcel> ,IParcelService
    {
        public ParcelService(CampingNeretvaRs2Context context, IMapper mapper) 
        :base(context, mapper){   
        }
    }
}
