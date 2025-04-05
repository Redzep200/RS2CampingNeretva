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
using CampingNeretva.Model.Requests;

namespace CampingNeretva.Service
{
    public class ParcelService : BaseCRUDService<ParcelModel, ParcelSearchObject, Parcel, ParcelInsertRequest, ParcelUpdateRequest> ,IParcelService
    {
        public ParcelService(CampingNeretvaRs2Context context, IMapper mapper) 
        :base(context, mapper){   
        }

        public override IQueryable<Parcel> AddFilter(ParcelSearchObject search, IQueryable<Parcel> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search?.ParcelNumber.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.ParcelNumber == search.ParcelNumber);
            }

            if (search?.Shade.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.Shade == search.Shade);
            }

            if (search?.Electricity.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.Electricity == search.Electricity);
            }

            if (search?.AvailabilityStatus.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.AvailabilityStatus == search.AvailabilityStatus);
            }

            return filteredQuery;
        }

        public override void beforeInsert(ParcelInsertRequest request, Parcel entity)
        {
            entity.AvailabilityStatus = true;
        }

    }
}
