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

            if (!string.IsNullOrWhiteSpace(search.ParcelTypeName))
            {
                filteredQuery = filteredQuery.Where(x =>
                    x.ParcelType != null &&
                    x.ParcelType.ParcelType1.ToLower().Contains(search.ParcelTypeName.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.ParcelAccommodationName))
            {
                filteredQuery = filteredQuery.Where(x =>
                    x.ParcelAccommodation != null &&
                    x.ParcelAccommodation.ParcelAccommodation1.ToLower().Contains(search.ParcelAccommodationName.ToLower()));
            }

            if (search?.DateFrom.HasValue == true && search?.DateTo.HasValue == true)
            {
                var reservedParcelIds = _context.Reservations
                    .Where(r =>
                        r.CheckInDate < search.DateTo.Value &&
                        r.CheckOutDate > search.DateFrom.Value)
                    .Select(r => r.ParcelId)
                    .ToList();

                filteredQuery = filteredQuery.Where(p => !reservedParcelIds.Contains(p.ParcelId));
            }

            Console.WriteLine($"ParcelTypeName: {search.ParcelTypeName}");
            Console.WriteLine($"ParcelAccommodationName: {search.ParcelAccommodationName}");
            return filteredQuery;
        }

        public override void beforeInsert(ParcelInsertRequest request, Parcel entity)
        {
            entity.AvailabilityStatus = true;
        }

        public override async Task<PagedResult<ParcelModel>> GetPaged(ParcelSearchObject search)
        {
            var result = await base.GetPaged(search);

            foreach (var parcel in result.ResultList)
            {
                parcel.Images = await _parcelImageService.GetImages(parcel.ParcelId);
            }

            return result;
        }

        public override async Task<ParcelModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _parcelImageService.GetImages(id);
            }

            return model;
        }
    }

}

