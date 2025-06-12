using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service
{
    public class RecommendationInitializer : IHostedService
    {
        private readonly IServiceProvider _serviceProvider;
        public static readonly MLContext _mlContext = new MLContext(seed: 42);
        public static ITransformer _parcelModel;
        public static ITransformer _activityModel;
        public static ITransformer _rentableItemModel;
        private static readonly object _lock = new object();

        public RecommendationInitializer(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<_200012Context>();
                var userPreferenceService = scope.ServiceProvider.GetRequiredService<IUserPreferenceService>();
                await TrainAndPopulateRecommendations(context, userPreferenceService, cancellationToken);
            }
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            return Task.CompletedTask;
        }

        private async Task TrainAndPopulateRecommendations(_200012Context context, IUserPreferenceService userPreferenceService, CancellationToken cancellationToken)
        {
            lock (_lock)
            {
                if (_parcelModel == null || _activityModel == null || _rentableItemModel == null)
                {
                    var parcelDataQuery = context.Reservations
                        .Include(r => r.User)
                        .ThenInclude(u => u.UserPreferences)
                        .Select(r => new
                        {
                            r.UserId,
                            r.ParcelId,
                            UserPrefs = r.User.UserPreferences.OrderByDescending(up => up.UserPreferenceId).FirstOrDefault()
                        })
                        .AsEnumerable();

                    var activityDataQuery = context.Reservations
                        .Include(r => r.Activities)
                        .Include(r => r.User)
                        .ThenInclude(u => u.UserPreferences)
                        .SelectMany(r => r.Activities, (r, a) => new
                        {
                            r.UserId,
                            ActivityId = a.ActivityId,
                            UserPrefs = r.User.UserPreferences.OrderByDescending(up => up.UserPreferenceId).FirstOrDefault()
                        })
                        .AsEnumerable();

                    var rentableItemDataQuery = context.ReservationRentables
                        .Include(rr => rr.Reservation)
                        .ThenInclude(r => r.User)
                        .ThenInclude(u => u.UserPreferences)
                        .Select(rr => new
                        {
                            UserId = rr.Reservation.UserId,
                            ItemId = rr.ItemId,
                            UserPrefs = rr.Reservation.User.UserPreferences.OrderByDescending(up => up.UserPreferenceId).FirstOrDefault()
                        })
                        .AsEnumerable();

                    var parcelData = parcelDataQuery
                        .Select(r => new ReservationData
                        {
                            UserId = r.UserId,
                            ItemId = r.ParcelId,
                            Label = 1.0f,
                            NumberOfPeople = r.UserPrefs?.NumberOfPeople ?? 0,
                            HasSmallChildren = r.UserPrefs?.HasSmallChildren ?? false,
                            HasSeniorTravelers = r.UserPrefs?.HasSeniorTravelers ?? false,
                            CarLength = r.UserPrefs?.CarLength ?? "Unknown",
                            HasDogs = r.UserPrefs?.HasDogs ?? false
                        })
                        .ToList();

                    var activityData = activityDataQuery
                        .Select(ra => new ReservationData
                        {
                            UserId = ra.UserId,
                            ItemId = ra.ActivityId,
                            Label = 1.0f,
                            NumberOfPeople = ra.UserPrefs?.NumberOfPeople ?? 0,
                            HasSmallChildren = ra.UserPrefs?.HasSmallChildren ?? false,
                            HasSeniorTravelers = ra.UserPrefs?.HasSeniorTravelers ?? false,
                            CarLength = ra.UserPrefs?.CarLength ?? "Unknown",
                            HasDogs = ra.UserPrefs?.HasDogs ?? false
                        })
                        .ToList();

                    var rentableItemData = rentableItemDataQuery
                        .Select(rr => new ReservationData
                        {
                            UserId = rr.UserId,
                            ItemId = rr.ItemId,
                            Label = 1.0f,
                            NumberOfPeople = rr.UserPrefs?.NumberOfPeople ?? 0,
                            HasSmallChildren = rr.UserPrefs?.HasSmallChildren ?? false,
                            HasSeniorTravelers = rr.UserPrefs?.HasSeniorTravelers ?? false,
                            CarLength = rr.UserPrefs?.CarLength ?? "Unknown",
                            HasDogs = rr.UserPrefs?.HasDogs ?? false
                        })
                        .ToList();

                    if (parcelData.Any(d => d.UserId < 0) || activityData.Any(d => d.UserId < 0) || rentableItemData.Any(d => d.UserId < 0))
                    {
                        Console.WriteLine("Error: Negative UserId values detected. Please ensure all UserId values are non-negative.");
                        return;
                    }

                    var parcelDataView = _mlContext.Data.LoadFromEnumerable(parcelData);
                    var activityDataView = _mlContext.Data.LoadFromEnumerable(activityData);
                    var rentableItemDataView = _mlContext.Data.LoadFromEnumerable(rentableItemData);

                    var parcelRowCount = parcelDataView.GetRowCount();
                    var activityRowCount = activityDataView.GetRowCount();
                    var rentableItemRowCount = rentableItemDataView.GetRowCount();

                    Console.WriteLine($"Parcel data rows: {parcelRowCount}, Activity data rows: {activityRowCount}, Rentable item data rows: {rentableItemRowCount}");

                    if (parcelRowCount < 50 || activityRowCount < 10 || rentableItemRowCount < 10)
                    {
                        Console.WriteLine("Insufficient data for ML.NET training. Using fallback recommendations for all users.");
                        PopulateFallbackRecommendations(context, userPreferenceService, cancellationToken).GetAwaiter().GetResult();
                        return;
                    }

                    _parcelModel = TrainModel(parcelData);
                    _activityModel = TrainModel(activityData);
                    _rentableItemModel = TrainModel(rentableItemData);
                }
            }

            await PopulateRecommendations(context, cancellationToken);
        }

        private ITransformer TrainModel(List<ReservationData> data)
        {
            var dataView = _mlContext.Data.LoadFromEnumerable(data);
            var pipeline = _mlContext.Transforms.Conversion.MapValueToKey("UserIdEncoded", "UserId")
                .Append(_mlContext.Transforms.Conversion.MapValueToKey("ItemIdEncoded", "ItemId"))
                .Append(_mlContext.Transforms.Conversion.ConvertType("NumberOfPeople", "Single"))
                .Append(_mlContext.Transforms.Conversion.ConvertType("HasSmallChildren", "Boolean"))
                .Append(_mlContext.Transforms.Conversion.ConvertType("HasSeniorTravelers", "Boolean"))
                .Append(_mlContext.Transforms.Conversion.ConvertType("HasDogs", "Boolean"))
                .Append(_mlContext.Transforms.Categorical.OneHotEncoding("CarLengthEncoded", "CarLength"))
                .Append(_mlContext.Transforms.Concatenate("Features", "NumberOfPeople", "HasSmallChildren", "HasSeniorTravelers", "HasDogs", "CarLengthEncoded"))
                .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(labelColumnName: "Label", matrixColumnIndexColumnName: "UserIdEncoded", matrixRowIndexColumnName: "ItemIdEncoded", numberOfIterations: 20, approximationRank: 100));
            return pipeline.Fit(dataView);
        }

        private async Task PopulateRecommendations(_200012Context context, CancellationToken cancellationToken)
        {
            context.UserRecommendations.RemoveRange(context.UserRecommendations);
            await context.SaveChangesAsync(cancellationToken);

            var users = await context.Users.ToListAsync(cancellationToken);
            var predictionEngineParcel = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(_parcelModel);
            var predictionEngineActivity = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(_activityModel);
            var predictionEngineRentable = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(_rentableItemModel);

            var newRecommendations = await CreateNewRecommendations(users, predictionEngineParcel, predictionEngineActivity, predictionEngineRentable, context, cancellationToken);
            await context.UserRecommendations.AddRangeAsync(newRecommendations, cancellationToken);
            await context.SaveChangesAsync(cancellationToken);
        }

        private async Task<List<UserRecommendation>> CreateNewRecommendations(IEnumerable<User> users, PredictionEngine<ReservationData, ItemPrediction> parcelEngine,
            PredictionEngine<ReservationData, ItemPrediction> activityEngine, PredictionEngine<ReservationData, ItemPrediction> rentableEngine,
            _200012Context context, CancellationToken cancellationToken)
        {
            var recommendations = new List<UserRecommendation>();
            foreach (var user in users)
            {
                var userPrefs = await context.UserPreferences
                    .Where(up => up.UserId == user.UserId)
                    .OrderByDescending(up => up.UserPreferenceId)
                    .FirstOrDefaultAsync(cancellationToken);
                var numberOfPeople = userPrefs?.NumberOfPeople ?? 0;
                var hasSmallChildren = userPrefs?.HasSmallChildren ?? false;
                var hasSeniorTravelers = userPrefs?.HasSeniorTravelers ?? false;
                var carLength = userPrefs?.CarLength ?? "Unknown";
                var hasDogs = userPrefs?.HasDogs ?? false;

                var parcelIds = context.Parcels.Select(p => p.ParcelId)
                    .Select(itemId => new
                    {
                        ItemId = itemId,
                        Score = parcelEngine.Predict(new ReservationData
                        {
                            UserId = user.UserId,
                            ItemId = itemId,
                            NumberOfPeople = numberOfPeople,
                            HasSmallChildren = hasSmallChildren,
                            HasSeniorTravelers = hasSeniorTravelers,
                            CarLength = carLength,
                            HasDogs = hasDogs
                        }).Score
                    })
                    .OrderByDescending(x => x.Score)
                    .Take(3)
                    .Select(x => x.ItemId)
                    .ToList();

                var activityIds = context.Activities.Select(a => a.ActivityId)
                    .Select(itemId => new
                    {
                        ItemId = itemId,
                        Score = activityEngine.Predict(new ReservationData
                        {
                            UserId = user.UserId,
                            ItemId = itemId,
                            NumberOfPeople = numberOfPeople,
                            HasSmallChildren = hasSmallChildren,
                            HasSeniorTravelers = hasSeniorTravelers,
                            CarLength = carLength,
                            HasDogs = hasDogs
                        }).Score
                    })
                    .OrderByDescending(x => x.Score)
                    .Take(2)
                    .Select(x => x.ItemId)
                    .ToList();

                var rentableItemIds = context.RentableItems.Select(ri => ri.ItemId)
                    .Select(itemId => new
                    {
                        ItemId = itemId,
                        Score = rentableEngine.Predict(new ReservationData
                        {
                            UserId = user.UserId,
                            ItemId = itemId,
                            NumberOfPeople = numberOfPeople,
                            HasSmallChildren = hasSmallChildren,
                            HasSeniorTravelers = hasSeniorTravelers,
                            CarLength = carLength,
                            HasDogs = hasDogs
                        }).Score
                    })
                    .OrderByDescending(x => x.Score)
                    .Take(2)
                    .Select(x => x.ItemId)
                    .ToList();

                recommendations.Add(new UserRecommendation
                {
                    UserId = user.UserId,
                    ParcelId1 = parcelIds.ElementAtOrDefault(0),
                    ParcelId2 = parcelIds.ElementAtOrDefault(1),
                    ParcelId3 = parcelIds.ElementAtOrDefault(2),
                    ActivityId1 = activityIds.ElementAtOrDefault(0),
                    ActivityId2 = activityIds.ElementAtOrDefault(1),
                    RentableItemId1 = rentableItemIds.ElementAtOrDefault(0),
                    RentableItemId2 = rentableItemIds.ElementAtOrDefault(1)
                });
            }
            return recommendations;
        }

        private async Task PopulateFallbackRecommendations(_200012Context context, IUserPreferenceService userPreferenceService, CancellationToken cancellationToken)
        {
            context.UserRecommendations.RemoveRange(context.UserRecommendations);
            await context.SaveChangesAsync(cancellationToken);

            var users = await context.Users.ToListAsync(cancellationToken);
            var newRecommendations = await CreateFallbackRecommendations(users, context, userPreferenceService, cancellationToken);
            await context.UserRecommendations.AddRangeAsync(newRecommendations, cancellationToken);
            await context.SaveChangesAsync(cancellationToken);
        }

        private async Task UpdateFallbackRecommendation(UserRecommendation recommendation, User user, _200012Context context,
            IUserPreferenceService userPreferenceService, CancellationToken cancellationToken)
        {
            var similarUsers = await userPreferenceService.FindSimilarUsers(user.UserId);
            if (!similarUsers.Any())
                return;

            var parcelIds = await context.Reservations
                .Include(r => r.Parcel)
                .Where(r => similarUsers.Contains(r.UserId))
                .Select(r => r.ParcelId)
                .Distinct()
                .Take(3)
                .ToListAsync(cancellationToken);

            var activityIds = await context.Reservations
                .Include(r => r.Activities)
                .Where(r => similarUsers.Contains(r.UserId))
                .SelectMany(r => r.Activities)
                .Select(a => a.ActivityId)
                .Distinct()
                .Take(2)
                .ToListAsync(cancellationToken);

            var rentableItemIds = await context.ReservationRentables
                .Include(rr => rr.Reservation)
                .Where(rr => similarUsers.Contains(rr.Reservation.UserId))
                .Select(rr => rr.ItemId)
                .Distinct()
                .Take(2)
                .ToListAsync(cancellationToken);

            recommendation.UserId = user.UserId;
            recommendation.ParcelId1 = parcelIds.ElementAtOrDefault(0);
            recommendation.ParcelId2 = parcelIds.ElementAtOrDefault(1);
            recommendation.ParcelId3 = parcelIds.ElementAtOrDefault(2);
            recommendation.ActivityId1 = activityIds.ElementAtOrDefault(0);
            recommendation.ActivityId2 = activityIds.ElementAtOrDefault(1);
            recommendation.RentableItemId1 = rentableItemIds.ElementAtOrDefault(0);
            recommendation.RentableItemId2 = rentableItemIds.ElementAtOrDefault(1);
        }

        private async Task<List<UserRecommendation>> CreateFallbackRecommendations(IEnumerable<User> users, _200012Context context,
            IUserPreferenceService userPreferenceService, CancellationToken cancellationToken)
        {
            var recommendations = new List<UserRecommendation>();
            foreach (var user in users)
            {
                var similarUsers = await userPreferenceService.FindSimilarUsers(user.UserId);
                if (!similarUsers.Any())
                    continue;

                var parcelIds = await context.Reservations
                    .Include(r => r.Parcel)
                    .Where(r => similarUsers.Contains(r.UserId))
                    .Select(r => r.ParcelId)
                    .Distinct()
                    .Take(3)
                    .ToListAsync(cancellationToken);

                var activityIds = await context.Reservations
                    .Include(r => r.Activities)
                    .Where(r => similarUsers.Contains(r.UserId))
                    .SelectMany(r => r.Activities)
                    .Select(a => a.ActivityId)
                    .Distinct()
                    .Take(2)
                    .ToListAsync(cancellationToken);

                var rentableItemIds = await context.ReservationRentables
                    .Include(rr => rr.Reservation)
                    .Where(rr => similarUsers.Contains(rr.Reservation.UserId))
                    .Select(rr => rr.ItemId)
                    .Distinct()
                    .Take(2)
                    .ToListAsync(cancellationToken);

                recommendations.Add(new UserRecommendation
                {
                    UserId = user.UserId,
                    ParcelId1 = parcelIds.ElementAtOrDefault(0),
                    ParcelId2 = parcelIds.ElementAtOrDefault(1),
                    ParcelId3 = parcelIds.ElementAtOrDefault(2),
                    ActivityId1 = activityIds.ElementAtOrDefault(0),
                    ActivityId2 = activityIds.ElementAtOrDefault(1),
                    RentableItemId1 = rentableItemIds.ElementAtOrDefault(0),
                    RentableItemId2 = rentableItemIds.ElementAtOrDefault(1)
                });
            }
            return recommendations;
        }
    }

    public class ReservationData
    {
        public int UserId { get; set; }
        public int ItemId { get; set; }
        public float Label { get; set; }
        public int NumberOfPeople { get; set; }
        public bool HasSmallChildren { get; set; }
        public bool HasSeniorTravelers { get; set; }
        public string CarLength { get; set; }
        public bool HasDogs { get; set; }
    }

    public class ItemPrediction
    {
        public float Score { get; set; }
    }
}