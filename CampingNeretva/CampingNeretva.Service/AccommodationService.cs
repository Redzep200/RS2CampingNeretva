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

        public override AccommodationModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _accommodationImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }

        public override PagedResult<AccommodationModel> GetPaged(AccommodationSearchObject search)
        {
            var result = base.GetPaged(search);

            foreach (var accommodation in result.ResultList)
            {
                accommodation.Images = _accommodationImageService.GetImages(accommodation.AccommodationId).GetAwaiter().GetResult();
            }

            return result;
        }

    }
}
