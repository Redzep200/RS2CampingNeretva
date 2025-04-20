using CampingNeretva.Model.ImageModels;
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
    public abstract class EntityImageService<TJoinEntity> where TJoinEntity : class
    {
        protected readonly _200012Context _context;
        protected readonly IMapper _mapper;

        public EntityImageService(_200012Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        protected abstract IQueryable<TJoinEntity> Query { get; }
        protected abstract DbSet<TJoinEntity> Set { get; }
        protected abstract DbSet<Image> ImageSet { get; }

        protected abstract int GetEntityId(TJoinEntity join);
        protected abstract int GetImageId(TJoinEntity join);
        protected abstract TJoinEntity CreateLink(int entityId, int imageId);
        protected abstract Image GetImage(TJoinEntity join);
        protected abstract Task<bool> LinkExistsAsync(int entityId, int imageId);

        // Add this new abstract method to get join entities for a specific entity
        protected abstract Task<List<TJoinEntity>> GetJoinEntitiesForEntityAsync(int entityId);

        public async Task<List<ImageModel>> GetImages(int entityId)
        {
            // Use the new abstract method that will be implemented with direct property access
            var joinEntities = await GetJoinEntitiesForEntityAsync(entityId);

            // Now that entities are loaded, we can safely use GetImage
            var images = joinEntities.Select(j => GetImage(j)).ToList();

            return _mapper.Map<List<ImageModel>>(images);
        }

        public async Task AddImage(int entityId, int imageId)
        {
            bool exists = await LinkExistsAsync(entityId, imageId);

            if (!exists)
            {
                var link = CreateLink(entityId, imageId);
                Set.Add(link);
                await _context.SaveChangesAsync();
            }
        }

        public async Task RemoveImage(int entityId, int imageId)
        {
            var allLinks = await Query.ToListAsync();
            var link = allLinks.FirstOrDefault(j => GetEntityId(j) == entityId && GetImageId(j) == imageId);

            if (link != null)
            {
                Set.Remove(link);
                await _context.SaveChangesAsync();
            }
        }
    }
}