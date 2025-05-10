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
            var parcelImages = await _context.ParcelImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (parcelImages.Any())
            {
                _context.ParcelImages.RemoveRange(parcelImages);
            }

            var accommodationImages = await _context.AccommodationImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (accommodationImages.Any())
            {
                _context.AccommodationImages.RemoveRange(accommodationImages);
            }

            var activityImages = await _context.ActivityImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (activityImages.Any())
            {
                _context.ActivityImages.RemoveRange(activityImages);
            }

            var facilityImages = await _context.FacilityImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (facilityImages.Any())
            {
                _context.FacilityImages.RemoveRange(facilityImages);
            }

            var personImages = await _context.PersonImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (personImages.Any())
            {
                _context.PersonImages.RemoveRange(personImages);
            }

            var vehicleImages = await _context.VehicleImages.Where(x => x.ImageId == imageId).ToListAsync();
            if (vehicleImages.Any())
            {
                _context.VehicleImages.RemoveRange(vehicleImages);
            }

            await _context.SaveChangesAsync();

            var image = await _context.Images
                .FirstOrDefaultAsync(x => x.ImageId == imageId);

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