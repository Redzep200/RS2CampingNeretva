using CampingNeretva.Service.Database;
using CampingNeretva.Service.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ActivityAnalysisController : ControllerBase
    {
        private readonly IActivityCommentAnalysisService _analysisService;
        private readonly _200012Context _context;
        private readonly ILogger<ActivityAnalysisController> _logger;

        public ActivityAnalysisController(
            IActivityCommentAnalysisService analysisService,
            _200012Context context,
            ILogger<ActivityAnalysisController> logger)
        {
            _analysisService = analysisService;
            _context = context;
            _logger = logger;
        }

        [HttpPost("analyze")]
        public async Task<IActionResult> AnalyzeComments()
        {
            await _analysisService.AnalyzeNewComments();
            return Ok(new { message = "Analysis completed" });
        }

        [HttpGet("notifications")]
        public async Task<IActionResult> GetNotifications()
        {
            var notifications = await _analysisService.GetPendingNotifications();
            return Ok(notifications);
        }

        [HttpPut("notifications/{id}/mark-read")]
        public async Task<IActionResult> MarkNotificationAsRead(int id)
        {
            try
            {
                _logger.LogInformation($"Attempting to mark notification {id} as read");

                var notification = await _context.ActivityCommentNotifications
                    .FirstOrDefaultAsync(n => n.NotificationId == id);

                if (notification == null)
                {
                    _logger.LogWarning($"Notification {id} not found");
                    return NotFound(new
                    {
                        success = false,
                        message = $"Notification with ID {id} not found"
                    });
                }

                _logger.LogInformation($"Found notification {id}, current status: {notification.Status}");

                // Update notification
                notification.Status = "Read";
                notification.DateReviewed = DateTime.Now;

                // Try to get and verify user ID from claims
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
                                ?? User.FindFirst("UserId")
                                ?? User.Claims.FirstOrDefault(c => c.Type.Contains("nameidentifier"));

                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
                {
                    // Verify user exists before setting ReviewedBy
                    var userExists = await _context.Users.AnyAsync(u => u.UserId == userId);

                    if (userExists)
                    {
                        notification.ReviewedBy = userId;
                        _logger.LogInformation($"Set ReviewedBy to user {userId}");
                    }
                    else
                    {
                        _logger.LogWarning($"User {userId} from claims does not exist in database, using default admin user 39");
                        notification.ReviewedBy = 39; // Fallback to known admin user
                    }
                }
                else
                {
                    _logger.LogWarning("Could not find user ID in claims, using default admin user 39");
                    notification.ReviewedBy = 39; // Fallback to known admin user
                }

                // Save changes
                var changeCount = await _context.SaveChangesAsync();
                _logger.LogInformation($"Saved {changeCount} changes to database");

                if (changeCount == 0)
                {
                    _logger.LogWarning("No changes were saved to database");
                }

                _logger.LogInformation($"Successfully marked notification {id} as read");

                return Ok(new
                {
                    success = true,
                    message = "Notification marked as read",
                    notificationId = id,
                    status = notification.Status,
                    dateReviewed = notification.DateReviewed,
                    reviewedBy = notification.ReviewedBy
                });
            }
            catch (DbUpdateException ex)
            {
                _logger.LogError(ex, $"Database error marking notification {id} as read");
                return StatusCode(500, new
                {
                    success = false,
                    message = "Database error occurred",
                    error = ex.InnerException?.Message ?? ex.Message
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error marking notification {id} as read");
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error marking notification as read",
                    error = ex.Message
                });
            }
        }

        [HttpGet("notifications/count")]
        public async Task<IActionResult> GetNotificationCount()
        {
            var count = await _context.ActivityCommentNotifications
                .Where(n => n.Status == "Pending")
                .CountAsync();

            return Ok(new { count });
        }

        // Helper endpoint to get current user info for debugging
        [HttpGet("current-user")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
                            ?? User.FindFirst("UserId")
                            ?? User.Claims.FirstOrDefault(c => c.Type.Contains("nameidentifier"));

            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                var userExists = await _context.Users.AnyAsync(u => u.UserId == userId);

                return Ok(new
                {
                    userId = userId,
                    userExists = userExists,
                    userName = User.Identity?.Name,
                    isAuthenticated = User.Identity?.IsAuthenticated ?? false,
                    roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList()
                });
            }

            return Ok(new
            {
                userId = (int?)null,
                userExists = false,
                userName = User.Identity?.Name,
                isAuthenticated = User.Identity?.IsAuthenticated ?? false,
                allClaims = User.Claims.Select(c => new { c.Type, c.Value }).ToList()
            });
        }
    }
}