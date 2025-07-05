using MapsterMapper;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service.ImageServices;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.Service.Services
{
    public class VehicleService : BaseCRUDService<VehicleModel, VehicleSearchObject, Vehicle, VehicleInsertRequest, VehicleUpdateRequest>, IVehicleService
    {
        private readonly VehicleImageService _vehicleImageService;

        public VehicleService(_200012Context context, IMapper mapper, VehicleImageService vehicleImageService)
        : base(context, mapper)
        {
            _vehicleImageService = vehicleImageService;
        }

        public override IQueryable<Vehicle> AddFilter(VehicleSearchObject search, IQueryable<Vehicle> query)
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

        public override async Task<VehicleModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _vehicleImageService.GetImages(id);
            }

            return model;
        }

        public override async Task<PagedResult<VehicleModel>> GetPaged(VehicleSearchObject search)
        {
            var result = await base.GetPaged(search);

            foreach (var vehicle in result.ResultList)
            {
                vehicle.Images = await _vehicleImageService.GetImages(vehicle.VehicleId);
            }

            return result;
        }


        public override async Task Delete(int id)
        {
            var vehicle = await _context.Vehicles.FindAsync(id);
            if (vehicle == null)
            {
                throw new Exception("Vehicle not found");
            }

            var relatedReservations = await _context.ReservationVehicles
                                          .Where(x => x.VehicleId == id)
                                          .ToListAsync();
            _context.ReservationVehicles.RemoveRange(relatedReservations);

            var vehicleImages = await _context.VehicleImages
                                      .Where(x => x.VehicleId == id)
                                      .ToListAsync();
            _context.VehicleImages.RemoveRange(vehicleImages);

            _context.Vehicles.Remove(vehicle);
            await _context.SaveChangesAsync();
        }


        public override async Task<VehicleModel> Insert(VehicleInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.VehicleImages.Add(new VehicleImage
            {
                VehicleId = entity.VehicleId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.VehicleId);
        }

        public override async Task<VehicleModel> Update(int id, VehicleUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            if (request.ImageId.HasValue && request.ImageId.Value > 0)
            {
                var existingLinks = await _context.VehicleImages.Where(x => x.VehicleId == id).ToListAsync();
                _context.VehicleImages.RemoveRange(existingLinks);

                _context.VehicleImages.Add(new VehicleImage
                {
                    VehicleId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();
            return await GetById(id);
        }
    }
}
