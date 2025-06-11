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
    public class ParcelImageService : EntityImageService<ParcelImage>
    {
        public ParcelImageService(_200012Context context, IMapper mapper)
        : base(context, mapper) { }

        protected override IQueryable<ParcelImage> Query => _context.ParcelImages.Include(x => x.Image);
        protected override DbSet<ParcelImage> Set => _context.ParcelImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(ParcelImage join) => join.ParcelId;
        protected override int GetImageId(ParcelImage join) => join.ImageId;
        protected override ParcelImage CreateLink(int entityId, int imageId) =>
            new ParcelImage { ParcelId = entityId, ImageId = imageId };
        protected override Image GetImage(ParcelImage join) => join.Image;

        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.ParcelImages
                .AnyAsync(x => x.ParcelId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<ParcelImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.ParcelImages
                .Include(x => x.Image)
                .Where(x => x.ParcelId == entityId)
                .ToListAsync();
        }
    }
}
