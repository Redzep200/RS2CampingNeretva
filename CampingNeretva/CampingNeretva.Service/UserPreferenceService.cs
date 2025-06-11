using CampingNeretva.Model.Requests;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

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
            var entity = await _context.UserPreferences.FirstOrDefaultAsync(up => up.UserId == userId);
            if (entity == null)
                throw new Exception("User preference not found");

            return _mapper.Map<UserPreferenceModel>(entity);
        }

        private async Task<List<int>> FindSimilarUsers(int userId)
        {
            var target = await _context.UserPreferences.FirstOrDefaultAsync(up => up.UserId == userId);
            if (target == null)
            {
                Console.WriteLine($"No preferences found for user {userId}");
                return new List<int>();
            }

            var allPreferences = await _context.UserPreferences.Where(up => up.UserId != userId).ToListAsync();
            var similarUsers = new List<int>();

            foreach (var pref in allPreferences)
            {
                double similarity = CalculateSimilarity(target, pref);
                if (similarity > 0.6)
                {
                    similarUsers.Add(pref.UserId);
                    Console.WriteLine($"Similar user: {pref.UserId} (sim={similarity})");
                }
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

        public async Task<List<ParcelModel>> GetRecommendedParcels(int userId)
        {
            var similarUsers = await FindSimilarUsers(userId);
            if (!similarUsers.Any())
                return new List<ParcelModel>();

            var parcels = await _context.Reservations
                .Include(r => r.Parcel)
                    .ThenInclude(p => p.ParcelAccommodation)
                .Include(r => r.Parcel)
                    .ThenInclude(p => p.ParcelType)
                .Where(r => similarUsers.Contains(r.UserId))
                .Select(r => r.Parcel)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<ParcelModel>>(parcels);
        }

        public async Task<List<ActivityModel>> GetRecommendedActivities(int userId)
        {
            var similarUsers = await FindSimilarUsers(userId);
            if (!similarUsers.Any())
                return new List<ActivityModel>();

            var activities = await _context.Reservations
                .Include(r => r.Activities)
                    .ThenInclude(a => a.ActivityImages)
                .Where(r => similarUsers.Contains(r.UserId))
                .SelectMany(r => r.Activities)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<ActivityModel>>(activities);
        }

        public async Task<List<RentableItemModel>> GetRecommendedRentableItems(int userId)
        {
            var similarUsers = await FindSimilarUsers(userId);
            if (!similarUsers.Any())
                return new List<RentableItemModel>();

            var rentableItems = await _context.ReservationRentables
                .Include(rr => rr.Reservation)
                .Include(rr => rr.Item)
                    .ThenInclude(i => i.RentableItemImages)
                .Where(rr => similarUsers.Contains(rr.Reservation.UserId))
                .Select(rr => rr.Item)
                .Distinct()
                .ToListAsync();


            return _mapper.Map<List<RentableItemModel>>(rentableItems);
        }
    }
}
