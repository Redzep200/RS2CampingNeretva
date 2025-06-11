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
    public class RentableItemImageService : EntityImageService<RentableItemImage>
    {
        public RentableItemImageService(_200012Context context, IMapper mapper)
        : base(context, mapper) { }

        protected override IQueryable<RentableItemImage> Query => _context.RentableItemImages.Include(x => x.Image);
        protected override DbSet<RentableItemImage> Set => _context.RentableItemImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(RentableItemImage join) => join.RentableItemId;
        protected override int GetImageId(RentableItemImage join) => join.ImageId;
        protected override RentableItemImage CreateLink(int entityId, int imageId) =>
            new RentableItemImage { RentableItemId = entityId, ImageId = imageId };
        protected override Image GetImage(RentableItemImage join) => join.Image;

        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.RentableItemImages
                .AnyAsync(x => x.RentableItemId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<RentableItemImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.RentableItemImages
                .Include(x => x.Image)
                .Where(x => x.RentableItemId == entityId)
                .ToListAsync();
        }
    }
}
