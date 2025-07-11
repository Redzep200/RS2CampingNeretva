﻿using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service.ImageServices;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.Service.Services
{
    public class FacilityService : BaseCRUDService<FacilityModel, FacilitySearchObject, Facility, FacilityInsertRequest, FacilityUpdateRequest>, IFacilityService
    {
        private readonly FacilityImageService _facilityImageService;
        public FacilityService(_200012Context context, IMapper mapper, FacilityImageService facilityImageService)
        : base(context, mapper)
        {
            _facilityImageService = facilityImageService;
        }

        public override IQueryable<Facility> AddFilter(FacilitySearchObject search, IQueryable<Facility> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FacilityTypeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.FacilityType.StartsWith(search.FacilityTypeGTE));
            }

            return filteredQuery;
        }

        public override async Task<FacilityModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _facilityImageService.GetImages(id);
            }

            return model;
        }

        public override async Task<PagedResult<FacilityModel>> GetPaged(FacilitySearchObject search)
        {
            var result = await base.GetPaged(search);

            foreach (var facility in result.ResultList)
            {
                facility.Images = await _facilityImageService.GetImages(facility.FacilityId);
            }

            return result;
        }

        public override async Task Delete(int id)
        {
            var facility = await _context.Facilities.FindAsync(id);
            if (facility == null)
            {
                throw new Exception("Facility not found");
            }

            var relatedActivities = await _context.Activities.Where(x => x.FacilityId == id).ToListAsync();
            _context.Activities.RemoveRange(relatedActivities);

            var facilityImages = await _context.FacilityImages.Where(x => x.FacilityId == id).ToListAsync();
            _context.FacilityImages.RemoveRange(facilityImages);

            _context.Facilities.Remove(facility);
            await _context.SaveChangesAsync();
        }

        public override async Task<FacilityModel> Insert(FacilityInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.FacilityImages.Add(new FacilityImage
            {
                FacilityId = entity.FacilityId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.FacilityId);
        }

        public override async Task<FacilityModel> Update(int id, FacilityUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            if (request.ImageId.HasValue && request.ImageId.Value > 0)
            {
                var existingLinks = await _context.FacilityImages.Where(x => x.FacilityId == id).ToListAsync();
                _context.FacilityImages.RemoveRange(existingLinks);

                _context.FacilityImages.Add(new FacilityImage
                {
                    FacilityId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }
}
