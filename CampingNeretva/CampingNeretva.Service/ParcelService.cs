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

        private readonly IImageService _imageService;

        public ParcelService(_200012Context context, IMapper mapper, IImageService imageService = null) 
        :base(context, mapper){
            _imageService = imageService;
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

        public override PagedResult<ParcelModel> GetPaged(ParcelSearchObject search)
        {
            // Get the base paged result
            var result = base.GetPaged(search);

            // If we have the image service, add images to each parcel
            if (_imageService != null)
            {
                foreach (var parcel in result.ResultList)
                {
                    parcel.Images = _imageService.GetByParcelId(parcel.ParcelId);
                }
            }

            return result;
        }

        public override ParcelModel GetById(int id)
        {
            var result = base.GetById(id);

            if (result != null && _imageService != null)
            {
                result.Images = _imageService.GetByParcelId(id);
            }

            return result;
        }
    }

}

