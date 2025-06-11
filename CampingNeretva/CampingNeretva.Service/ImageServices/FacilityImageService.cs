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
    public class FacilityImageService : EntityImageService<FacilityImage>
    {
        public FacilityImageService(_200012Context context, IMapper mapper)
            : base(context, mapper) { }

        protected override IQueryable<FacilityImage> Query => _context.FacilityImages.Include(x => x.Image);
        protected override DbSet<FacilityImage> Set => _context.FacilityImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(FacilityImage join) => join.FacilityId;
        protected override int GetImageId(FacilityImage join) => join.ImageId;
        protected override FacilityImage CreateLink(int entityId, int imageId) =>
            new FacilityImage { FacilityId = entityId, ImageId = imageId };
        protected override Image GetImage(FacilityImage join) => join.Image;

        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.FacilityImages
                .AnyAsync(x => x.FacilityId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<FacilityImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.FacilityImages
                .Include(x => x.Image)
                .Where(x => x.FacilityId == entityId)
                .ToListAsync();
        }
    }
}
