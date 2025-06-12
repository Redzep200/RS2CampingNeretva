using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IUserPreferenceService
    {
        Task<UserPreferenceModel> Insert(int userId, UserPreferenceInsertRequest request);
        Task<UserPreferenceModel> Update(int userId, UserPreferenceUpdateRequest request);
        Task<UserPreferenceModel> GetByUserId(int userId);
        Task<List<ParcelModel>> GetRecommendedParcels(int userId);
        Task<List<ActivityModel>> GetRecommendedActivities(int userId);
        Task<List<RentableItemModel>> GetRecommendedRentableItems(int userId);
        Task<List<int>> FindSimilarUsers(int userId);
    }
}