using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Security.Claims;
using CampingNeretva.Service.Database;

namespace CampingNeretva.API.Controllers;

[ApiController]
[Route("[controller]")]
public class UserPreferenceController : ControllerBase
{
    private readonly IUserPreferenceService _service;
    private readonly _200012Context _context; // Inject context if needed for user lookup

    public UserPreferenceController(IUserPreferenceService service, _200012Context context)
    {
        _service = service;
        _context = context; // Add context to constructor
    }

    [HttpPost]
    [Authorize]
    public async Task<UserPreferenceModel> Insert([FromBody] UserPreferenceInsertRequest request)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
            throw new UnauthorizedAccessException("User not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        if (user == null)
            throw new NotFoundException("User not found");

        return await _service.Insert(user.UserId, request);
    }

    [HttpPut]
    [Authorize]
    public async Task<UserPreferenceModel> Update([FromBody] UserPreferenceUpdateRequest request)
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
            throw new UnauthorizedAccessException("User not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        if (user == null)
            throw new NotFoundException("User not found");

        return await _service.Update(user.UserId, request);
    }

    [HttpGet("recommended/parcels")]
    [Authorize]
    public async Task<List<ParcelModel>> GetRecommendedParcels()
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
            throw new UnauthorizedAccessException("User not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        if (user == null)
            throw new NotFoundException("User not found");

        return await _service.GetRecommendedParcels(user.UserId);
    }

    [HttpGet("recommended/activities")]
    [Authorize]
    public async Task<List<ActivityModel>> GetRecommendedActivities()
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
            throw new UnauthorizedAccessException("User not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        if (user == null)
            throw new NotFoundException("User not found");

        return await _service.GetRecommendedActivities(user.UserId);
    }

    [HttpGet("recommended/rentable-items")]
    [Authorize]
    public async Task<List<RentableItemModel>> GetRecommendedRentableItems()
    {
        var username = User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
            throw new UnauthorizedAccessException("User not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        if (user == null)
            throw new NotFoundException("User not found");

        return await _service.GetRecommendedRentableItems(user.UserId);
    }
}

public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}