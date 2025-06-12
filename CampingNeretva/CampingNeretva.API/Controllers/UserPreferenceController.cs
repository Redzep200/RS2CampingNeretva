using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Security.Claims;
using CampingNeretva.Service.Database;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserPreferenceController : ControllerBase
    {
        private readonly IUserPreferenceService _service;
        private readonly _200012Context _context;

        public UserPreferenceController(IUserPreferenceService service, _200012Context context)
        {
            _service = service;
            _context = context;
        }

        private async Task<int> GetCurrentUserId()
        {
            var username = User.Identity?.Name ?? throw new UnauthorizedAccessException("User not authenticated");
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
            return user?.UserId ?? throw new NotFoundException("User not found");
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> Get()
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.GetByUserId(userId);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Insert([FromBody] UserPreferenceInsertRequest request)
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.Insert(userId, request);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPut]
        [Authorize]
        public async Task<IActionResult> Update([FromBody] UserPreferenceUpdateRequest request)
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.Update(userId, request);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("recommended/parcels")]
        [Authorize]
        public async Task<IActionResult> GetRecommendedParcels()
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.GetRecommendedParcels(userId);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("recommended/activities")]
        [Authorize]
        public async Task<IActionResult> GetRecommendedActivities()
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.GetRecommendedActivities(userId);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("recommended/rentable-items")]
        [Authorize]
        public async Task<IActionResult> GetRecommendedRentableItems()
        {
            try
            {
                var userId = await GetCurrentUserId();
                var response = await _service.GetRecommendedRentableItems(userId);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
    }

    public class NotFoundException : Exception
    {
        public NotFoundException(string message) : base(message) { }
    }
}