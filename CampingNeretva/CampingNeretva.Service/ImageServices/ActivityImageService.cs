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
    public class ActivityImageService : EntityImageService<ActivityImage>
    {
        public ActivityImageService(_200012Context context, IMapper mapper)
        : base(context, mapper) { }

        protected override IQueryable<ActivityImage> Query => _context.ActivityImages.Include(x => x.Image);
        protected override DbSet<ActivityImage> Set => _context.ActivityImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(ActivityImage join) => join.ActivityId;
        protected override int GetImageId(ActivityImage join) => join.ImageId;
        protected override ActivityImage CreateLink(int entityId, int imageId) =>
            new ActivityImage { ActivityId = entityId, ImageId = imageId };
        protected override Image GetImage(ActivityImage join) => join.Image;

        // Implement the new abstract method with direct property access
        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.ActivityImages
                .AnyAsync(x => x.ActivityId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<ActivityImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.ActivityImages
                .Include(x => x.Image)
                .Where(x => x.ActivityId == entityId)
                .ToListAsync();
        }
    }
}

