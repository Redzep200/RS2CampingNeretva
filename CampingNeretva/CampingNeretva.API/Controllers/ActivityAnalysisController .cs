using CampingNeretva.Service.Database;
using CampingNeretva.Service.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ActivityAnalysisController : ControllerBase
    {
        private readonly IActivityCommentAnalysisService _analysisService;
        private readonly _200012Context _context;

        public ActivityAnalysisController(IActivityCommentAnalysisService analysisService, _200012Context context)
        {
            _analysisService = analysisService;
            _context = context;
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
            var notification = await _context.ActivityCommentNotifications.FindAsync(id);
            if (notification == null) return NotFound();

            notification.Status = "Read";
            notification.DateReviewed = DateTime.Now;
            notification.ReviewedBy = 1; 
            await _context.SaveChangesAsync();

            return Ok(new { message = "Notification marked as read" });
        }
    }
}