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
            _uploadPath = uploadPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "uploads", "images");

            // Create directory if it doesn't exist
            if (!Directory.Exists(_uploadPath))
                Directory.CreateDirectory(_uploadPath);
        }

        public async Task<ImageModel> UploadImage(Stream fileStream, string fileName, string contentType)
        {
            try
            {
                if (fileStream == null)
                    throw new ArgumentException("No file stream provided");

                // Create unique filename
                string uniqueFileName = Guid.NewGuid().ToString() + "_" + fileName;
                string filePath = Path.Combine(_uploadPath, uniqueFileName);

                // Save the file
                using (var outputStream = new FileStream(filePath, FileMode.Create))
                {
                    await fileStream.CopyToAsync(outputStream);
                }

                // Create database record
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

        public List<ImageModel> GetByParcelId(int parcelId)
        {
            var images = _context.ParcelImages
                .Include(pi => pi.Image)
                .Where(pi => pi.ParcelId == parcelId)
                .Select(pi => pi.Image)
                .ToList();

            return Mapper.Map<List<ImageModel>>(images);
        }

        public async Task AddImageToParcel(int parcelId, int imageId)
        {
            // Check if relationship already exists
            var exists = await _context.ParcelImages
                .AnyAsync(pi => pi.ParcelId == parcelId && pi.ImageId == imageId);

            if (!exists)
            {
                _context.ParcelImages.Add(new ParcelImage
                {
                    ParcelId = parcelId,
                    ImageId = imageId
                });

                await _context.SaveChangesAsync();
            }
        }

        public async Task RemoveImageFromParcel(int parcelId, int imageId)
        {
            var parcelImage = await _context.ParcelImages
                .FirstOrDefaultAsync(pi => pi.ParcelId == parcelId && pi.ImageId == imageId);

            if (parcelImage != null)
            {
                _context.ParcelImages.Remove(parcelImage);
                await _context.SaveChangesAsync();
            }
        }

        public override void beforeInsert(ImageUploadRequest request, Image entity)
        {
            // This will be handled by the UploadImage method
        }
    }
}