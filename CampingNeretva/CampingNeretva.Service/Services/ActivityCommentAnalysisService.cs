using CampingNeretva.Service.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.ML;
using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Services
{
    public class CommentData
    {
        [LoadColumn(0)]
        public string CommentText { get; set; }

        [LoadColumn(1)]
        public string Category { get; set; }
    }

    public class CommentPrediction
    {
        [ColumnName("PredictedLabel")]
        public string Category { get; set; }

        public float[] Score { get; set; }
    }

    public interface IActivityCommentAnalysisService
    {
        Task AnalyzeNewComments();
        Task<List<CommentAnalysisResult>> GetPendingNotifications();
    }

    public class CommentAnalysisResult
    {
        public int NotificationId { get; set; }
        public int ActivityId { get; set; }
        public string ActivityName { get; set; }
        public string Category { get; set; }
        public string Sentiment { get; set; }
        public List<ActivityComment> RelatedComments { get; set; }
        public string AISummary { get; set; }
        public DateTime DateCreated { get; set; }
    }

    public class ActivityCommentAnalysisService : IActivityCommentAnalysisService
    {
        private readonly _200012Context _context;
        private static readonly MLContext _mlContext = new MLContext(seed: 1);
        private static ITransformer _model;
        private static readonly object _lock = new object();
        private readonly IConfiguration _configuration;

        public ActivityCommentAnalysisService(_200012Context context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
            InitializeModel();
        }

        private void InitializeModel()
        {
            lock (_lock)
            {
                if (_model == null)
                {
                    var trainingData = new List<CommentData>
                    {
                        new CommentData { CommentText = "too expensive", Category = "Price" },
                        new CommentData { CommentText = "cost too much", Category = "Price" },
                        new CommentData { CommentText = "overpriced for what you get", Category = "Price" },
                        new CommentData { CommentText = "poor value", Category = "Price" },
                        new CommentData { CommentText = "not worth the money", Category = "Price" },
                        new CommentData { CommentText = "super affordable", Category = "Price" },
                        new CommentData { CommentText = "great value", Category = "Price" },

    // STAFF issues
                        new CommentData { CommentText = "staff was rude", Category = "Staff" },
                        new CommentData { CommentText = "unfriendly workers", Category = "Staff" },
                        new CommentData { CommentText = "guide had bad attitude", Category = "Staff" },
                        new CommentData { CommentText = "not helpful", Category = "Staff" },
                        new CommentData { CommentText = "super friendly staff", Category = "Staff" },
                        new CommentData { CommentText = "polite and kind", Category = "Staff" },

    // TIME issues
                        new CommentData { CommentText = "too short", Category = "Time" },
                        new CommentData { CommentText = "too long", Category = "Time" },
                        new CommentData { CommentText = "we waited forever", Category = "Time" },
                        new CommentData { CommentText = "delayed start", Category = "Time" },
                        new CommentData { CommentText = "perfect timing", Category = "Time" },

    // QUALITY issues
                        new CommentData { CommentText = "boring activity", Category = "Quality" },
                        new CommentData { CommentText = "amazing experience", Category = "Quality" },
                        new CommentData { CommentText = "poor quality equipment", Category = "Quality" },
                        new CommentData { CommentText = "badly organized", Category = "Quality" },
                        new CommentData { CommentText = "very fun and engaging", Category = "Quality" },
                        new CommentData { CommentText = "low quality service", Category = "Quality" },

    // SAFETY issues
                        new CommentData { CommentText = "felt unsafe", Category = "Safety" },
                        new CommentData { CommentText = "instructor ignored safety rules", Category = "Safety" },
                        new CommentData { CommentText = "equipment dangerous", Category = "Safety" },
                        new CommentData { CommentText = "we almost got hurt", Category = "Safety" },
                        new CommentData { CommentText = "safe and secure", Category = "Safety" },
                        new CommentData { CommentText = "clear safety instructions", Category = "Safety" },
                    };

                    var dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

                    var pipeline = _mlContext.Transforms.Text
                        .FeaturizeText("Features", nameof(CommentData.CommentText))
                        .Append(_mlContext.Transforms.Conversion.MapValueToKey("Label", nameof(CommentData.Category)))
                        .Append(_mlContext.MulticlassClassification.Trainers.SdcaMaximumEntropy("Label", "Features"))
                        .Append(_mlContext.Transforms.Conversion.MapKeyToValue("PredictedLabel", "Label"));

                    _model = pipeline.Fit(dataView);
                }
            }
        }

        public async Task AnalyzeNewComments()
        {
            var sevenDaysAgo = DateTime.Now.AddDays(-7);

            // Get all comment IDs that are already in notifications
            var usedCommentIds = await _context.ActivityCommentNotifications
                .Select(n => n.RelatedCommentIds)
                .ToListAsync();

            var allUsedCommentIds = new HashSet<int>();
            foreach (var commentIdsString in usedCommentIds)
            {
                var ids = commentIdsString
                    .Split(',', StringSplitOptions.RemoveEmptyEntries)
                    .Select(id => int.Parse(id.Trim()));

                foreach (var id in ids)
                {
                    allUsedCommentIds.Add(id);
                }
            }

            Console.WriteLine($"Found {allUsedCommentIds.Count} comments already used in notifications");

            // Get recent comments that haven't been used in any notification yet
            var recentComments = await _context.ActivityComments
                .Where(c => c.DatePosted >= sevenDaysAgo && !allUsedCommentIds.Contains(c.ActivityCommentId))
                .Include(c => c.Activity)
                .Include(c => c.User)
                .ToListAsync();

            Console.WriteLine($"Found {recentComments.Count} new comments to analyze (not in existing notifications)");

            if (!recentComments.Any())
            {
                Console.WriteLine("No new comments to analyze");
                return;
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<CommentData, CommentPrediction>(_model);

            var groupedAnalysis = recentComments
                .Select(c => new
                {
                    Comment = c,
                    Prediction = predictionEngine.Predict(new CommentData { CommentText = c.CommentText }),
                    Sentiment = DetermineSentiment(c.CommentText, c.Rating)
                })
                .GroupBy(x => new { x.Comment.ActivityId, x.Prediction.Category })
                .Where(g => g.Count() >= 3)
                .ToList();

            Console.WriteLine($"Found {groupedAnalysis.Count} groups with 3+ comments in same category");

            foreach (var group in groupedAnalysis)
            {
                var negativeComments = group.Where(x => x.Sentiment == "Negative").ToList();

                if (negativeComments.Count >= 2)
                {
                    Console.WriteLine($"Processing group: Activity {group.Key.ActivityId}, Category {group.Key.Category}, {negativeComments.Count} negative comments");

                    // Check if a notification for this activity + category already exists
                    var existingNotification = await _context.ActivityCommentNotifications
                        .FirstOrDefaultAsync(n =>
                            n.ActivityId == group.Key.ActivityId &&
                            n.Category == group.Key.Category &&
                            n.Status == "Pending");

                    if (existingNotification == null)
                    {
                        await CreateAINotification(
                            group.Key.ActivityId,
                            group.Key.Category,
                            negativeComments.Select(x => x.Comment).ToList()
                        );
                    }
                    else
                    {
                        Console.WriteLine($"Skipping - notification already exists for Activity {group.Key.ActivityId}, Category {group.Key.Category}");
                    }
                }
            }
        }

        private string DetermineSentiment(string commentText, int rating)
        {
            if (rating <= 2) return "Negative";
            if (rating >= 4) return "Positive";

            var negativeKeywords = new[] { "bad", "poor", "terrible", "awful", "disappointed", "disappointing",
    "rude", "unfriendly", "hostile", "unprofessional",
    "expensive", "overpriced", "pricey", "cost too much",
    "unsafe", "dangerous", "risk", "not safe",
    "dirty", "filthy", "unclean", "messy",
    "boring", "waste of time", "not worth", "regret",
    "late", "delay", "slow", "took too long",
    "broken", "malfunction", "damaged",
    "crowded", "too many people", "overcrowded",
    "noisy", "loud",
    "poor quality", "low quality", "cheap materials" };
            var lowerText = commentText.ToLower();

            if (negativeKeywords.Any(keyword => lowerText.Contains(keyword)))
                return "Negative";

            return "Neutral";
        }

        private async Task CreateAINotification(int activityId, string category, List<ActivityComment> comments)
        {
            var aiSummary = await GenerateAISummary(activityId, category, comments);

            var notification = new ActivityCommentNotification
            {
                ActivityId = activityId,
                Category = category,
                Sentiment = "Negative",
                Summary = aiSummary,
                RelatedCommentIds = string.Join(",", comments.Select(c => c.ActivityCommentId)),
                Status = "Pending",
                DateCreated = DateTime.Now
            };

            _context.ActivityCommentNotifications.Add(notification);
            await _context.SaveChangesAsync();

            Console.WriteLine($"Created notification {notification.NotificationId} for Activity {activityId}, Category {category}");
        }

        private async Task<string> GenerateAISummary(int activityId, string category, List<ActivityComment> comments)
        {
            var activity = await _context.Activities.FindAsync(activityId);

            var prompt = $@"You are analyzing customer feedback for a camping activity: '{activity.Name}'.

Category: {category}
Number of comments: {comments.Count}

Comments:
{string.Join("\n", comments.Select((c, i) => $"{i + 1}. Rating {c.Rating}/5: {c.CommentText}"))}

Please provide:
1. A brief summary of the main issue (2-3 sentences)
2. Specific actionable recommendations for improvement
3. Estimated impact if not addressed (Low/Medium/High)

Keep the response concise and focused on actionable insights.";

            try
            {
                var apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY");

                if (string.IsNullOrEmpty(apiKey))
                {
                    Console.WriteLine("❌ ERROR: OPENAI_API_KEY not configured!");
                    return $"AI analysis unavailable - API key not configured. Manual review recommended for {comments.Count} negative comments in {category} category.";
                }

                Console.WriteLine($"🔍 Making API call to OpenAI for Activity {activityId}...");
                Console.WriteLine($"🔑 API Key available: {!string.IsNullOrEmpty(apiKey)}");

                using var httpClient = new HttpClient();
                httpClient.Timeout = TimeSpan.FromSeconds(120);
                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

                var apiUrl = "https://api.openai.com/v1/chat/completions";

                var requestBody = new
                {
                    model = "gpt-3.5-turbo",
                    messages = new[]
                    {
                        new
                        {
                            role = "system",
                            content = "You are an expert at analyzing customer feedback for camping activities. Provide concise, actionable insights."
                        },
                        new
                        {
                            role = "user",
                            content = prompt
                        }
                    },
                    max_tokens = 300,
                    temperature = 0.7
                };

                Console.WriteLine($"📤 Sending request to OpenAI API...");

                var response = await httpClient.PostAsJsonAsync(apiUrl, requestBody);

                Console.WriteLine($"📊 Response status: {response.StatusCode}");

                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"❌ API Error Response: {errorContent}");

                    if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                    {
                        return $"AI analysis failed - Invalid API key. Manual review recommended for {comments.Count} negative comments in {category} category.";
                    }
                    else if (response.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
                    {
                        return $"AI analysis failed - Rate limit exceeded. Manual review recommended for {comments.Count} negative comments in {category} category.";
                    }
                    else
                    {
                        return $"AI analysis failed (HTTP {response.StatusCode}). Manual review recommended for {comments.Count} negative comments in {category} category.";
                    }
                }

                var json = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"📥 Response size: {json.Length} bytes");

                // Parse OpenAI response
                var parsedResponse = Newtonsoft.Json.Linq.JObject.Parse(json);
                var generatedText = parsedResponse["choices"]?[0]?["message"]?["content"]?.ToString();

                if (!string.IsNullOrEmpty(generatedText))
                {
                    Console.WriteLine($"✅ Successfully generated AI summary ({generatedText.Length} characters)");
                    return generatedText.Trim();
                }

                Console.WriteLine("⚠️ API response had no content");
                return $"AI analysis unavailable - empty response. Manual review recommended for {comments.Count} negative comments in {category} category.";
            }
            catch (HttpRequestException httpEx)
            {
                Console.WriteLine($"❌ HTTP Request Error: {httpEx.Message}");
                return $"AI analysis failed - Network error. Manual review recommended for {comments.Count} negative comments in {category} category.";
            }
            catch (TaskCanceledException timeoutEx)
            {
                Console.WriteLine($"❌ Request Timeout: {timeoutEx.Message}");
                return $"AI analysis failed - Request timeout. Manual review recommended for {comments.Count} negative comments in {category} category.";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Exception generating AI summary: {ex.GetType().Name} - {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return $"AI analysis failed. Manual review recommended for {comments.Count} negative comments in {category} category.";
            }
        }

        public async Task<List<CommentAnalysisResult>> GetPendingNotifications()
        {
            var notifications = await _context.ActivityCommentNotifications
                .Where(n => n.Status == "Pending")
                .Include(n => n.Activity)
                .OrderByDescending(n => n.DateCreated)
                .ToListAsync();

            var results = new List<CommentAnalysisResult>();

            foreach (var notif in notifications)
            {
                var commentIds = notif.RelatedCommentIds
                    .Split(',', StringSplitOptions.RemoveEmptyEntries)
                    .Select(id => int.Parse(id))
                    .ToList();

                var comments = await _context.ActivityComments
                    .Where(c => commentIds.Contains(c.ActivityCommentId))
                    .ToListAsync();

                var sanitizedComments = comments.Select(c => new ActivityComment
                {
                    ActivityCommentId = c.ActivityCommentId,
                    ActivityId = c.ActivityId,
                    UserId = c.UserId,
                    CommentText = c.CommentText,
                    Rating = c.Rating,
                    DatePosted = c.DatePosted,
                    Activity = null,
                    User = null
                }).ToList();

                results.Add(new CommentAnalysisResult
                {
                    NotificationId = notif.NotificationId,
                    ActivityId = notif.ActivityId,
                    ActivityName = notif.Activity?.Name ?? "Unknown",
                    Category = notif.Category,
                    Sentiment = notif.Sentiment,
                    AISummary = notif.Summary,
                    RelatedComments = sanitizedComments,
                    DateCreated = notif.DateCreated
                });
            }

            return results;
        }
    }
}