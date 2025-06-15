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
using CampingNeretva.Model.DTO;

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

        public async Task<List<UnavailableParcelModel>> GetUnavailableParcels(DateTime dateFrom, DateTime dateTo)
        {
            var unavailableParcels = await _context.Reservations
                .Where(r => r.CheckInDate < dateTo && r.CheckOutDate > dateFrom)
                .Select(r => r.Parcel)
                .Distinct()
                .Select(p => new UnavailableParcelModel
                {
                    ParcelId = p.ParcelId,
                    ParcelNumber = p.ParcelNumber
                })
                .ToListAsync();

            return unavailableParcels;
        }

        public override async Task Delete(int id)
        {
            var parcel = await _context.Parcels.FindAsync(id);
            if (parcel == null)
            {
                throw new Exception("Parcel not found");
            }
            var relatedReservations = await _context.Reservations
                                      .Where(x => x.ParcelId == id)
                                      .ToListAsync();
            _context.Reservations.RemoveRange(relatedReservations);

            var parcelImages = await _context.ParcelImages.Where(x => x.ParcelId == id).ToListAsync();
            _context.ParcelImages.RemoveRange(parcelImages);

            var relatedRecommendation = await _context.UserRecommendations.Where(x=> x.ParcelId1 ==  id || x.ParcelId2 == id || x.ParcelId3 == id).ToListAsync();
            _context.UserRecommendations.RemoveRange(relatedRecommendation);

            _context.Parcels.Remove(parcel);
            await _context.SaveChangesAsync();
        }

        public override async Task<ParcelModel> Insert(ParcelInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.ParcelImages.Add(new ParcelImage
            {
                ParcelId = entity.ParcelId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.ParcelId);
        }

        public override async Task<ParcelModel> Update(int id, ParcelUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            if (request.ImageId.HasValue && request.ImageId.Value > 0)
            {
                var existingLinks = await _context.ParcelImages.Where(x => x.ParcelId == id).ToListAsync();
                _context.ParcelImages.RemoveRange(existingLinks);

                _context.ParcelImages.Add(new ParcelImage
                {
                    ParcelId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }

}

