using CampingNeretva.Model.ImageModels;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ImageController : BaseController<ImageModel, BaseSearchObject>
    {
        private readonly IImageService _imageService;

        public ImageController(IImageService service) : base(service)
        {
            _imageService = service;
        }

        [HttpPost("upload")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Upload(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest("No file uploaded");

                using (var stream = file.OpenReadStream())
                {
                    var result = await _imageService.UploadImage(stream, file.FileName, file.ContentType);
                    return Ok(result);
                }
            }
            catch (System.Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{imageId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveImage(int imageId)
        {
            await _imageService.RemoveImage(imageId);
            return Ok();
        }
    }
}