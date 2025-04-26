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
using CampingNeretva.Service.ImageServices;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service
{
    public class ParcelService : BaseCRUDService<ParcelModel, ParcelSearchObject, Parcel, ParcelInsertRequest, ParcelUpdateRequest> ,IParcelService
    {

        private readonly ParcelImageService _parcelImageService;

        public ParcelService(_200012Context context, IMapper mapper, ParcelImageService parcelImageService) 
        :base(context, mapper){
            _parcelImageService = parcelImageService;
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

            if (search?.IsParcelAccommodationIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ParcelAccommodation);
            }

            if (search?.IsParcelTypeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.ParcelType);
            }

            return filteredQuery;
        }

        public override void beforeInsert(ParcelInsertRequest request, Parcel entity)
        {
            entity.AvailabilityStatus = true;
        }

        public override PagedResult<ParcelModel> GetPaged(ParcelSearchObject search)
        {
            var result = base.GetPaged(search);

            if (search.DateFrom.HasValue && search.DateTo.HasValue)
            {
                var reservedParcelIds = _context.Reservations
                    .Where(r =>
                        r.CheckInDate < search.DateTo.Value &&
                        r.CheckOutDate > search.DateFrom.Value)
                    .Select(r => r.ParcelId)
                    .ToList();

                result.ResultList = result.ResultList
                    .Where(p => !reservedParcelIds.Contains(p.ParcelId))
                    .ToList();
            }

            foreach (var parcel in result.ResultList)
            {
                parcel.Images = _parcelImageService.GetImages(parcel.ParcelId).GetAwaiter().GetResult();
            }

            return result;
        }

        public override ParcelModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _parcelImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }
    }

}

