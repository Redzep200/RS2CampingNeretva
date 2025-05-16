using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.ImageServices
{
    public class VehicleImageService : EntityImageService<VehicleImage>
    {
        public VehicleImageService(_200012Context context, IMapper mapper)
            : base(context, mapper) { }

        protected override IQueryable<VehicleImage> Query => _context.VehicleImages.Include(x => x.Image);
        protected override DbSet<VehicleImage> Set => _context.VehicleImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(VehicleImage join) => join.VehicleId;
        protected override int GetImageId(VehicleImage join) => join.ImageId;
        protected override VehicleImage CreateLink(int entityId, int imageId) =>
            new VehicleImage { VehicleId = entityId, ImageId = imageId };
        protected override Image GetImage(VehicleImage join) => join.Image;

        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.VehicleImages
                .AnyAsync(x => x.VehicleId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<VehicleImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.VehicleImages
                .Include(x => x.Image)
                .Where(x => x.VehicleId == entityId)
                .ToListAsync();
        }
    }
}
