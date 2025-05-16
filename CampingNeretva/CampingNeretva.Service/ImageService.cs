// CampingNeretva.Service/ImageService.cs
using CampingNeretva.Model.ImageModels;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class ImageService : BaseCRUDService<ImageModel, BaseSearchObject, Image, ImageUploadRequest, ImageUploadRequest>, IImageService
    {
        private readonly string _uploadPath;

        public ImageService(_200012Context context, IMapper mapper, string uploadPath = null)
            : base(context, mapper)
        {
            _uploadPath = uploadPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "images");

            if (!Directory.Exists(_uploadPath))
                Directory.CreateDirectory(_uploadPath);
        }

        public async Task<ImageModel> UploadImage(Stream fileStream, string fileName, string contentType)
        {
            try
            {
                if (fileStream == null)
                    throw new ArgumentException("No file stream provided");

                string uniqueFileName = Guid.NewGuid().ToString() + "_" + fileName;
                string filePath = Path.Combine(_uploadPath, uniqueFileName);

                using (var outputStream = new FileStream(filePath, FileMode.Create))
                {
                    await fileStream.CopyToAsync(outputStream);
                }

                var image = new Image
                {
                    Path = "/uploads/images/" + uniqueFileName,
                    DateCreated = DateTime.Now,
                    ContentType = contentType
                };

                _context.Add(image);
                await _context.SaveChangesAsync();

                return Mapper.Map<ImageModel>(image);
            }
            catch (Exception ex)
            {
                throw new Exception("Error uploading image: " + ex.Message);
            }
        }



        public async Task RemoveImage(int imageId)
        {
            async Task RemoveRelated<TEntity>(DbSet<TEntity> set) where TEntity : class
            {
                var list = await set.Where(x => EF.Property<int>(x, "ImageId") == imageId).ToListAsync();
                if (list.Any())
                {
                    set.RemoveRange(list);
                }
            }

            await RemoveRelated(_context.ParcelImages);
            await RemoveRelated(_context.AccommodationImages);
            await RemoveRelated(_context.ActivityImages);
            await RemoveRelated(_context.FacilityImages);
            await RemoveRelated(_context.PersonImages);
            await RemoveRelated(_context.VehicleImages);

            await _context.SaveChangesAsync();

            var image = await _context.Images.FirstOrDefaultAsync(x => x.ImageId == imageId);
            if (image != null)
            {
                _context.Images.Remove(image);
                await _context.SaveChangesAsync();

                string filePath = Path.Combine(_uploadPath, Path.GetFileName(image.Path));
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                }
            }
        }

        public override void beforeInsert(ImageUploadRequest request, Image entity)
        {
            
        }
    }
}