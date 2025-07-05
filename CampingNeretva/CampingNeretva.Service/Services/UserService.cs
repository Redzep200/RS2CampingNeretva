using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using Microsoft.ML;
using Microsoft.ML.Data;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.Service.Services
{
    public class UserService : BaseCRUDService<UserModel, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IUserPreferenceService _userPreferenceService;
        private readonly IReservationService _reservationService;
        private static readonly MLContext _mlContext = new MLContext(seed: 42);
        private static ITransformer _parcelModel;
        private static ITransformer _activityModel;
        private static ITransformer _rentableItemModel;
        private static readonly object _lock = new object();

        public UserService(_200012Context context, IMapper mapper, IUserPreferenceService userPreferenceService, IReservationService reservationService)
            : base(context, mapper)
        {
            _userPreferenceService = userPreferenceService;
            _reservationService = reservationService;
        }

        public override async Task<UserModel> Insert(UserInsertRequest request)
        {
            var entity = Mapper.Map<User>(request);
            beforeInsert(request, entity);

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            await GenerateRecommendationsForUser(entity.UserId);

            return Mapper.Map<UserModel>(entity);
        }

        public override void beforeInsert(UserInsertRequest request, User entity)
        {
            if (_context.Users.Any(u => u.UserName == request.UserName))
            {
                throw new Exception("Username is already taken");
            }

            if (_context.Users.Any(u => u.Email == request.Email))
            {
                throw new Exception("Email is already in use");
            }

            if (request.UserTypeId.HasValue)
            {
                var type = _context.UserTypes.FirstOrDefault(x => x.UserTypeId == request.UserTypeId.Value);
                if (type == null)
                    throw new Exception("Korisnička uloga ne postoji");

                entity.UserType = type;
            }
            else
            {
                var guestType = _context.UserTypes.FirstOrDefault(x => x.TypeName == "Guest");
                if (guestType != null)
                    entity.UserType = guestType;
                else
                    throw new Exception("Role *Guest* has been removed");
            }

            if (request.Password != request.PasswordConfirmation)
                throw new Exception("Password and PasswordConfirmation are different");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
        }

        public override IQueryable<User> AddFilter(UserSearchObject search, IQueryable<User> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FirstNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.StartsWith(search.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(search.LastNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.LastName.StartsWith(search.LastNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(search.UserName))
            {
                filteredQuery = filteredQuery.Where(x => x.UserName.Contains(search.UserName));
            }

            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                filteredQuery = filteredQuery.Where(x => x.Email.Equals(search.Email));
            }

            if (search?.IsUserTypeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.UserType);
            }

            return filteredQuery;
        }

        public static string GenerateSalt()
        {
            var byteArray = RandomNumberGenerator.GetBytes(16);
            return Convert.ToBase64String(byteArray);
        }

        public string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public UserModel Login(string username, string password)
        {
            var entity = _context.Users.Include(x => x.UserType).FirstOrDefault(x => x.UserName == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
            {
                return null;
            }

            return Mapper.Map<UserModel>(entity);
        }

        public override async Task Delete(int id)
        {
            using (var transaction = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    var user = await _context.Users.FindAsync(id);
                    if (user == null)
                    {
                        throw new Exception("User not found");
                    }

                    var relatedReservations = await _context.Reservations
                        .Where(x => x.UserId == id)
                        .ToListAsync();
                    foreach (var reservation in relatedReservations)
                    {
                        await _reservationService.Delete(reservation.ReservationId);
                    }

                    var relatedReviews = await _context.Reviews.Where(x => x.UserId == id).ToListAsync();
                    _context.Reviews.RemoveRange(relatedReviews);

                    var relatedRecommendations = await _context.UserRecommendations.Where(x => x.UserId == id).ToListAsync();
                    _context.UserRecommendations.RemoveRange(relatedRecommendations);

                    var relatedPreferences = await _context.UserPreferences.Where(x => x.UserId == id).ToListAsync();
                    _context.UserPreferences.RemoveRange(relatedPreferences);

                    var relatedPayments = await _context.Payments.Where(x => x.UserId == id).ToListAsync();
                    _context.Payments.RemoveRange(relatedPayments);

                    _context.Users.Remove(user);
                    await _context.SaveChangesAsync();

                    await transaction.CommitAsync();
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    throw new Exception($"Failed to delete user: {ex.Message}", ex);
                }
            }
        }

        public async Task<UserModel> UpdateOwnProfile(string username, UserUpdateRequest request)
        {
            var user = _context.Users.Include(u => u.UserType)
                                    .FirstOrDefault(u => u.UserName == username);

            if (user == null)
                throw new Exception("User not found");

            if (!string.IsNullOrWhiteSpace(request.UserName) && request.UserName != username)
            {
                if (_context.Users.Any(u => u.UserName == request.UserName))
                    throw new Exception("Username is already taken");
                user.UserName = request.UserName;
            }

            if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email)
            {
                if (_context.Users.Any(u => u.Email == request.Email))
                    throw new Exception("Email is already in use");
                user.Email = request.Email;
            }

            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                user.PhoneNumber = request.PhoneNumber;

            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                if (request.Password != request.PasswordConfirmation)
                    throw new Exception("Passwords do not match");

                user.PasswordSalt = GenerateSalt();
                user.PasswordHash = GenerateHash(user.PasswordSalt, request.Password);
            }

            await _context.SaveChangesAsync();
            return Mapper.Map<UserModel>(user);
        }

        private async Task GenerateRecommendationsForUser(int userId)
        {
            var context = _context;
            var user = await context.Users.FindAsync(userId);
            if (user == null) return;

            ITransformer parcelModel, activityModel, rentableItemModel;
            lock (_lock)
            {
                parcelModel = _parcelModel;
                activityModel = _activityModel;
                rentableItemModel = _rentableItemModel;
            }

            if (parcelModel == null || activityModel == null || rentableItemModel == null)
            {
                await PopulateFallbackRecommendationsForUser(user, context, _userPreferenceService);
                return;
            }

            var predictionEngineParcel = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(parcelModel);
            var predictionEngineActivity = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(activityModel);
            var predictionEngineRentable = _mlContext.Model.CreatePredictionEngine<ReservationData, ItemPrediction>(rentableItemModel);

            var userPrefs = await context.UserPreferences
                .Where(up => up.UserId == userId)
                .OrderByDescending(up => up.UserPreferenceId)
                .FirstOrDefaultAsync();
            var numberOfPeople = userPrefs?.NumberOfPeople ?? 0;
            var hasSmallChildren = userPrefs?.HasSmallChildren ?? false;
            var hasSeniorTravelers = userPrefs?.HasSeniorTravelers ?? false;
            var carLength = userPrefs?.CarLength ?? "Unknown";
            var hasDogs = userPrefs?.HasDogs ?? false;

            var parcelIds = context.Parcels.Select(p => p.ParcelId)
                .Select(itemId => new
                {
                    ItemId = itemId,
                    predictionEngineParcel.Predict(new ReservationData
                    {
                        UserId = userId,
                        ItemId = itemId,
                        NumberOfPeople = numberOfPeople,
                        HasSmallChildren = hasSmallChildren,
                        HasSeniorTravelers = hasSeniorTravelers,
                        CarLength = carLength,
                        HasDogs = hasDogs
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Where(x => x.Score > 0)
                .Take(3)
                .Select(x => x.ItemId)
                .DefaultIfEmpty()
                .ToList();

            var activityIds = context.Activities.Select(a => a.ActivityId)
                .Select(itemId => new
                {
                    ItemId = itemId,
                    predictionEngineActivity.Predict(new ReservationData
                    {
                        UserId = userId,
                        ItemId = itemId,
                        NumberOfPeople = numberOfPeople,
                        HasSmallChildren = hasSmallChildren,
                        HasSeniorTravelers = hasSeniorTravelers,
                        CarLength = carLength,
                        HasDogs = hasDogs
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Where(x => x.Score > 0)
                .Take(2)
                .Select(x => x.ItemId)
                .DefaultIfEmpty()
                .ToList();

            var rentableItemIds = context.RentableItems.Select(ri => ri.ItemId)
                .Select(itemId => new
                {
                    ItemId = itemId,
                    predictionEngineRentable.Predict(new ReservationData
                    {
                        UserId = userId,
                        ItemId = itemId,
                        NumberOfPeople = numberOfPeople,
                        HasSmallChildren = hasSmallChildren,
                        HasSeniorTravelers = hasSeniorTravelers,
                        CarLength = carLength,
                        HasDogs = hasDogs
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Where(x => x.Score > 0)
                .Take(2)
                .Select(x => x.ItemId)
                .DefaultIfEmpty()
                .ToList();

            var recommendation = new UserRecommendation
            {
                UserId = userId,
                ParcelId1 = parcelIds.ElementAtOrDefault(0) > 0 ? parcelIds.ElementAtOrDefault(0) : null,
                ParcelId2 = parcelIds.ElementAtOrDefault(1) > 0 ? parcelIds.ElementAtOrDefault(1) : null,
                ParcelId3 = parcelIds.ElementAtOrDefault(2) > 0 ? parcelIds.ElementAtOrDefault(2) : null,
                ActivityId1 = activityIds.ElementAtOrDefault(0) > 0 ? activityIds.ElementAtOrDefault(0) : null,
                ActivityId2 = activityIds.ElementAtOrDefault(1) > 0 ? activityIds.ElementAtOrDefault(1) : null,
                RentableItemId1 = rentableItemIds.ElementAtOrDefault(0) > 0 ? rentableItemIds.ElementAtOrDefault(0) : null,
                RentableItemId2 = rentableItemIds.ElementAtOrDefault(1) > 0 ? rentableItemIds.ElementAtOrDefault(1) : null
            };

            context.UserRecommendations.Add(recommendation);
            await context.SaveChangesAsync();
        }

        private async Task PopulateFallbackRecommendationsForUser(User user, _200012Context context, IUserPreferenceService userPreferenceService)
        {
            var recommendation = new UserRecommendation { UserId = user.UserId };
            await UpdateFallbackRecommendation(recommendation, user, context, userPreferenceService);
            context.UserRecommendations.Add(recommendation);
            await context.SaveChangesAsync();
        }

        private async Task UpdateFallbackRecommendation(UserRecommendation recommendation, User user, _200012Context context,
            IUserPreferenceService userPreferenceService)
        {
            var similarUsers = await userPreferenceService.FindSimilarUsers(user.UserId);
            if (!similarUsers.Any())
            {
                recommendation.ParcelId1 = context.Reservations
                    .GroupBy(r => r.ParcelId)
                    .OrderByDescending(g => g.Count())
                    .Select(g => g.Key)
                    .FirstOrDefault();
                recommendation.ActivityId1 = context.Reservations
                    .SelectMany(r => r.Activities)
                    .GroupBy(a => a.ActivityId)
                    .OrderByDescending(g => g.Count())
                    .Select(g => g.Key)
                    .FirstOrDefault();
                recommendation.RentableItemId1 = context.ReservationRentables
                    .GroupBy(rr => rr.ItemId)
                    .OrderByDescending(g => g.Count())
                    .Select(g => g.Key)
                    .FirstOrDefault();
                return;
            }

            var parcelIds = await context.Reservations
                .Include(r => r.Parcel)
                .Where(r => similarUsers.Contains(r.UserId))
                .Select(r => r.ParcelId)
                .Distinct()
                .Take(3)
                .ToListAsync();

            var activityIds = await context.Reservations
                .Include(r => r.Activities)
                .Where(r => similarUsers.Contains(r.UserId))
                .SelectMany(r => r.Activities)
                .Select(a => a.ActivityId)
                .Distinct()
                .Take(2)
                .ToListAsync();

            var rentableItemIds = await context.ReservationRentables
                .Include(rr => rr.Reservation)
                .Where(rr => similarUsers.Contains(rr.Reservation.UserId))
                .Select(rr => rr.ItemId)
                .Distinct()
                .Take(2)
                .ToListAsync();

            recommendation.ParcelId1 = parcelIds.ElementAtOrDefault(0);
            recommendation.ParcelId2 = parcelIds.ElementAtOrDefault(1);
            recommendation.ParcelId3 = parcelIds.ElementAtOrDefault(2);
            recommendation.ActivityId1 = activityIds.ElementAtOrDefault(0);
            recommendation.ActivityId2 = activityIds.ElementAtOrDefault(1);
            recommendation.RentableItemId1 = rentableItemIds.ElementAtOrDefault(0);
            recommendation.RentableItemId2 = rentableItemIds.ElementAtOrDefault(1);
        }
    }
}