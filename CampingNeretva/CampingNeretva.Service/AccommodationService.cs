using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Service.ImageServices;

namespace CampingNeretva.Service
{
    public class AccommodationService : BaseCRUDService<AccommodationModel, AccommodationSearchObject, Accommodation, AcommodationInsertRequest, AcommodationUpdateRequest>, IAccommodationService
    {
        private readonly AccommodationImageService _accommodationImageService;
        public AccommodationService(_200012Context context, IMapper mapper, AccommodationImageService accommodationImageService)
        : base(context, mapper)
        {
            _accommodationImageService = accommodationImageService;
        }

        public override IQueryable<Accommodation> AddFilter(AccommodationSearchObject search, IQueryable<Accommodation> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Type.StartsWith(search.TypeGTE));
            }

            if (search?.PricePerNightGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.PricePerNight == search.PricePerNightGTE);
            }

            return filteredQuery;
        }

        public override async Task<AccommodationModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _accommodationImageService.GetImages(id);
            }

            return model;
        }

        public override async Task<PagedResult<AccommodationModel>> GetPaged(AccommodationSearchObject search)
        {
            var result = await base.GetPaged(search);

            foreach (var accommodation in result.ResultList)
            {
                accommodation.Images = await _accommodationImageService.GetImages(accommodation.AccommodationId);
            }

            return result;
        }


        public override async Task Delete(int id)
        {
            var accommodation = await _context.Accommodations.FindAsync(id);
            if (accommodation == null)
            {
                throw new Exception("Accommodation not found");
            }
            var relatedReservations = await _context.ReservationAccommodations
                                      .Where(x => x.AccommodationId == id)
                                      .ToListAsync();
            _context.ReservationAccommodations.RemoveRange(relatedReservations);

            var accommodationImages = await _context.AccommodationImages.Where(x => x.AccommodationId == id).ToListAsync();
            _context.AccommodationImages.RemoveRange(accommodationImages);

            _context.Accommodations.Remove(accommodation);
            await _context.SaveChangesAsync();
        }

        public override async Task<AccommodationModel> Insert(AcommodationInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.AccommodationImages.Add(new AccommodationImage
            {
                AccommodationId = entity.AccommodationId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.AccommodationId);
        }

        public override async Task<AccommodationModel> Update(int id, AcommodationUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            if (request.ImageId.HasValue && request.ImageId.Value > 0) { 
                var existingLinks = await _context.AccommodationImages.Where(x => x.AccommodationId == id).ToListAsync();
            _context.AccommodationImages.RemoveRange(existingLinks);

                _context.AccommodationImages.Add(new AccommodationImage
                {
                    AccommodationId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }
}
