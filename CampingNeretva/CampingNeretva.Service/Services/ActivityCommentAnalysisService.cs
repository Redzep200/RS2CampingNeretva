using CampingNeretva.Service.Database;
using EasyNetQ;
using EasyNetQ.DI;
using EasyNetQ.Serialization.NewtonsoftJson;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Text.RegularExpressions;

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
        public int ActivityId { get; set; }
        public string ActivityName { get; set; }
        public string Category { get; set; }
        public string Sentiment { get; set; }
        public List<ActivityComment> RelatedComments { get; set; }
        public string AISummary { get; set; }
    }

    public class ActivityCommentAnalysisService : IActivityCommentAnalysisService
    {
        private readonly _200012Context _context;
        private static readonly MLContext _mlContext = new MLContext(seed: 1);
        private static ITransformer _model;
        private static readonly object _lock = new object();

        public ActivityCommentAnalysisService(_200012Context context)
        {
            _context = context;
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
                new CommentData { CommentText = "great value for money", Category = "Price" },
                new CommentData { CommentText = "overpriced", Category = "Price" },
                new CommentData { CommentText = "cheap", Category = "Price" },
                new CommentData { CommentText = "cost", Category = "Price" },

                new CommentData { CommentText = "staff was rude", Category = "Staff" },
                new CommentData { CommentText = "friendly workers", Category = "Staff" },
                new CommentData { CommentText = "guide was helpful", Category = "Staff" },
                new CommentData { CommentText = "unprofessional", Category = "Staff" },

                new CommentData { CommentText = "too short", Category = "Time" },
                new CommentData { CommentText = "lasted too long", Category = "Time" },
                new CommentData { CommentText = "perfect duration", Category = "Time" },
                new CommentData { CommentText = "late start", Category = "Time" },

                new CommentData { CommentText = "amazing experience", Category = "Quality" },
                new CommentData { CommentText = "boring", Category = "Quality" },
                new CommentData { CommentText = "well organized", Category = "Quality" },
                new CommentData { CommentText = "poor quality", Category = "Quality" },

                new CommentData { CommentText = "felt unsafe", Category = "Safety" },
                new CommentData { CommentText = "dangerous equipment", Category = "Safety" },
                new CommentData { CommentText = "no safety briefing", Category = "Safety" },
                new CommentData { CommentText = "safe and secure", Category = "Safety" },
            };

                    var dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

                    var pipeline = _mlContext.Transforms.Text
                        .FeaturizeText("Features", nameof(CommentData.CommentText))

                        .Append(_mlContext.Transforms.Conversion.MapValueToKey(
                            "Label",
                            nameof(CommentData.Category)
                        ))

                        .Append(_mlContext.MulticlassClassification.Trainers
                            .SdcaMaximumEntropy("Label", "Features"))

                        .Append(_mlContext.Transforms.Conversion.MapKeyToValue(
                            "PredictedLabel",
                            "Label"
                        ));

                    _model = pipeline.Fit(dataView);
                }
            }
        }


        public async Task AnalyzeNewComments()
        {
            var sevenDaysAgo = DateTime.Now.AddDays(-7);
            var recentComments = await _context.ActivityComments
                .Where(c => c.DatePosted >= sevenDaysAgo)
                .Include(c => c.Activity)
                .Include(c => c.User)
                .ToListAsync();

            if (!recentComments.Any()) return;

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

            foreach (var group in groupedAnalysis)
            {
                var negativeComments = group.Where(x => x.Sentiment == "Negative").ToList();

                if (negativeComments.Count >= 2)
                {
                    await CreateAINotification(
                        group.Key.ActivityId,
                        group.Key.Category,
                        negativeComments.Select(x => x.Comment).ToList()
                    );
                }
            }
        }

        private string DetermineSentiment(string commentText, int rating)
        {
            // Simple sentiment based on rating and keywords
            if (rating <= 2) return "Negative";
            if (rating >= 4) return "Positive";

            var negativeKeywords = new[] { "bad", "poor", "terrible", "awful", "disappointed",
                                          "rude", "expensive", "overpriced", "unsafe" };
            var lowerText = commentText.ToLower();

            if (negativeKeywords.Any(keyword => lowerText.Contains(keyword)))
                return "Negative";

            return "Neutral";
        }

        private async Task CreateAINotification(int activityId, string category, List<ActivityComment> comments)
        {
            // Use Claude API for AI summary
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

            // Send via RabbitMQ
            await SendNotificationViaRabbitMQ(notification);
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
                using var httpClient = new HttpClient();
                httpClient.DefaultRequestHeaders.Add("x-api-key", Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY"));
                httpClient.DefaultRequestHeaders.Add("anthropic-version", "2023-06-01");

                var body = new
                {
                    model = "claude-3-sonnet-20240229",
                    max_tokens = 500,
                    messages = new[]
                    {
                new { role = "user", content = prompt }
            }
                };

                var response = await httpClient.PostAsJsonAsync(
                    "https://api.anthropic.com/v1/messages",
                    body
                );

                var json = await response.Content.ReadAsStringAsync();

                // Use Newtonsoft.Json instead
                var parsed = Newtonsoft.Json.Linq.JObject.Parse(json);
                var contentArray = parsed["content"] as Newtonsoft.Json.Linq.JArray;

                if (contentArray != null && contentArray.Count > 0)
                {
                    var firstItem = contentArray[0] as Newtonsoft.Json.Linq.JObject;
                    var text = firstItem?["text"]?.ToString();
                    return text ?? "AI analysis unavailable";
                }

                return "AI analysis unavailable - no content returned";
            }
            catch (Exception ex)
            {
                return $"Analysis failed: {ex.Message}. Manual review recommended for {comments.Count} negative comments in {category} category.";
            }
        }

        private async Task SendNotificationViaRabbitMQ(ActivityCommentNotification notification)
        {
            try
            {
                using var bus = RabbitHutch.CreateBus("host=rabbitmq", x =>
                    x.Register<ISerializer>(_ => new NewtonsoftJsonSerializer()));

                await bus.PubSub.PublishAsync(notification, "activity_comment_notifications");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RabbitMQ notification failed: {ex.Message}");
            }
        }

        public async Task<List<CommentAnalysisResult>> GetPendingNotifications()
        {
            var notifications = await _context.ActivityCommentNotifications
                .Where(n => n.Status == "Pending")
                .Include(n => n.Activity)
                .ToListAsync();

            var results = new List<CommentAnalysisResult>();

            foreach (var notif in notifications)
            {
                // Parse comment IDs from string
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
                    ActivityId = notif.ActivityId,
                    ActivityName = notif.Activity?.Name ?? "Unknown",
                    Category = notif.Category,
                    Sentiment = notif.Sentiment,
                    AISummary = notif.Summary,
                    RelatedComments = sanitizedComments
                });
            }

            return results;
        }
    }
}