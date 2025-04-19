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
using CampingNeretva.Service.ImageServices;

namespace CampingNeretva.Service
{
    public class VehicleService : BaseCRUDService<VehicleModel, VehicleSearchObject, Vehicle, VehicleInsertRequest, VehicleUpdateRequest>, IVehicleService
    {
        private readonly VehicleImageService _vehicleImageService;

        public VehicleService(_200012Context context, IMapper mapper, VehicleImageService vehicleImageService)
        :base(context, mapper){
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

        public override VehicleModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _vehicleImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }

        public override PagedResult<VehicleModel> GetPaged(VehicleSearchObject search)
        {
            var result = base.GetPaged(search);

            foreach (var vehicle in result.ResultList)
            {
                vehicle.Images = _vehicleImageService.GetImages(vehicle.VehicleId).GetAwaiter().GetResult();
            }

            return result;
        }

    }
}
