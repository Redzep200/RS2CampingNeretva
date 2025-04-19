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
    public class PersonImageService : EntityImageService<PersonImage>
    {
        public PersonImageService(_200012Context context, IMapper mapper)
            : base(context, mapper) { }

        protected override IQueryable<PersonImage> Query => _context.PersonImages.Include(x => x.Image);
        protected override DbSet<PersonImage> Set => _context.PersonImages;
        protected override DbSet<Image> ImageSet => _context.Images;

        protected override int GetEntityId(PersonImage join) => join.PersonId;
        protected override int GetImageId(PersonImage join) => join.ImageId;
        protected override PersonImage CreateLink(int entityId, int imageId) =>
            new PersonImage { PersonId = entityId, ImageId = imageId };
        protected override Image GetImage(PersonImage join) => join.Image;

        protected override async Task<bool> LinkExistsAsync(int entityId, int imageId)
        {
            return await _context.PersonImages
                .AnyAsync(x => x.PersonId == entityId && x.ImageId == imageId);
        }

        protected override async Task<List<PersonImage>> GetJoinEntitiesForEntityAsync(int entityId)
        {
            return await _context.PersonImages
                .Include(x => x.Image)
                .Where(x => x.PersonId == entityId)
                .ToListAsync();
        }
    }
}
