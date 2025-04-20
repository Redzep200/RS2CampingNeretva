using CampingNeretva.Model.ImageModels;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IImageService : ICRUDService<ImageModel, BaseSearchObject, ImageUploadRequest, ImageUploadRequest>
    {
        Task<ImageModel> UploadImage(Stream fileStream, string fileName, string contentType);
        Task RemoveImage(int imageId);
    }
}