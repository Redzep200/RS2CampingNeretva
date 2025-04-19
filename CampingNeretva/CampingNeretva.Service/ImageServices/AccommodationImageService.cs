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
    public class AccommodationImageService : EntityImageService<AccommodationImage>
    {
        public AccommodationImageService(_200012Context context, IMapper mapper)
            : base(context, mapper) { }

        protected override IQueryable<AccommodationImage> Query => _context.AccommodationImages.Include(x => x.Image);
        protected override DbSet<AccommodationImage> Set => _context.AccommodationImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(AccommodationImage join) => join.AccommodationId;
        protected override int GetImageId(AccommodationImage join) => join.ImageId;
        protected override AccommodationImage CreateLink(int entityId, int imageId) =>
            new AccommodationImage { AccommodationId = entityId, ImageId = imageId };
        protected override Image GetImage(AccommodationImage join) => join.Image;

        // Implement the new abstract method with direct property access
        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.AccommodationImages
                .AnyAsync(x => x.AccommodationId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<AccommodationImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.AccommodationImages
                .Include(x => x.Image)
                .Where(x => x.AccommodationId == entityId)
                .ToListAsync();
        }
    }
}