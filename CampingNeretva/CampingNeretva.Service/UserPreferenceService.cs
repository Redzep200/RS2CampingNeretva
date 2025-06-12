using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Service.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class UserPreferenceService : IUserPreferenceService
    {
        private readonly _200012Context _context;
        private readonly IMapper _mapper;

        public UserPreferenceService(_200012Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<UserPreferenceModel> Insert(int userId, UserPreferenceInsertRequest request)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                throw new Exception("User not found");

            var entity = _mapper.Map<UserPreference>(request);
            entity.UserId = userId;

            _context.UserPreferences.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<UserPreferenceModel>(entity);
        }

        public async Task<UserPreferenceModel> Update(int userId, UserPreferenceUpdateRequest request)
        {
            var entity = await _context.UserPreferences.FirstOrDefaultAsync(up => up.UserId == userId);
            if (entity == null)
                throw new Exception("User preference not found");

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<UserPreferenceModel>(entity);
        }

        public async Task<UserPreferenceModel> GetByUserId(int userId)
        {
            var entity = await _context.UserPreferences
                .OrderByDescending(up => up.UserPreferenceId)
                .FirstOrDefaultAsync(up => up.UserId == userId);
            if (entity == null)
                throw new Exception("User preference not found");

            return _mapper.Map<UserPreferenceModel>(entity);
        }

        public async Task<List<ParcelModel>> GetRecommendedParcels(int userId)
        {
            var recommendation = await _context.UserRecommendations
                .FirstOrDefaultAsync(ur => ur.UserId == userId);
            if (recommendation == null)
                return new List<ParcelModel>();

            var parcelIds = new[] { recommendation.ParcelId1, recommendation.ParcelId2, recommendation.ParcelId3 }
                .Where(id => id.HasValue)
                .Select(id => id.Value)
                .ToList();

            var parcels = await _context.Parcels
                .Include(p => p.ParcelAccommodation)
                .Include(p => p.ParcelType)
                .Include(p => p.ParcelImages)
                .Where(p => parcelIds.Contains(p.ParcelId))
                .ToListAsync();

            return _mapper.Map<List<ParcelModel>>(parcels);
        }

        public async Task<List<ActivityModel>> GetRecommendedActivities(int userId)
        {
            var recommendation = await _context.UserRecommendations
                .FirstOrDefaultAsync(ur => ur.UserId == userId);
            if (recommendation == null)
                return new List<ActivityModel>();

            var activityIds = new[] { recommendation.ActivityId1, recommendation.ActivityId2 }
                .Where(id => id.HasValue)
                .Select(id => id.Value)
                .ToList();

            var activities = await _context.Activities
                .Include(a => a.Facility)
                .Include(a => a.ActivityImages)
                .Where(a => activityIds.Contains(a.ActivityId))
                .ToListAsync();

            return _mapper.Map<List<ActivityModel>>(activities);
        }

        public async Task<List<RentableItemModel>> GetRecommendedRentableItems(int userId)
        {
            var recommendation = await _context.UserRecommendations
                .FirstOrDefaultAsync(ur => ur.UserId == userId);
            if (recommendation == null)
                return new List<RentableItemModel>();

            var rentableItemIds = new[] { recommendation.RentableItemId1, recommendation.RentableItemId2 }
                .Where(id => id.HasValue)
                .Select(id => id.Value)
                .ToList();

            var rentableItems = await _context.RentableItems
                .Include(ri => ri.RentableItemImages)
                .Where(ri => rentableItemIds.Contains(ri.ItemId))
                .ToListAsync();

            return _mapper.Map<List<RentableItemModel>>(rentableItems);
        }

        public async Task<List<int>> FindSimilarUsers(int userId)
        {
            var target = await _context.UserPreferences
                .OrderByDescending(up => up.UserPreferenceId)
                .FirstOrDefaultAsync(up => up.UserId == userId);
            if (target == null)
                return new List<int>();

            var allPreferences = await _context.UserPreferences
                .Where(up => up.UserId != userId)
                .ToListAsync();
            var similarUsers = new List<int>();

            foreach (var pref in allPreferences)
            {
                double similarity = CalculateSimilarity(target, pref);
                if (similarity > 0.6)
                    similarUsers.Add(pref.UserId);
            }

            return similarUsers;
        }

        private double CalculateSimilarity(UserPreference target, UserPreference other)
        {
            int matches = 0;
            int total = 5;

            if (target.NumberOfPeople == other.NumberOfPeople) matches++;
            if (target.HasSmallChildren == other.HasSmallChildren) matches++;
            if (target.HasSeniorTravelers == other.HasSeniorTravelers) matches++;
            if (target.CarLength == other.CarLength) matches++;
            if (target.HasDogs == other.HasDogs) matches++;

            return (double)matches / total;
        }
    }
}