using CampingNeretva.Model;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IUserService : ICRUDService<UserModel, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        UserModel Login(string username, string password);
        public string GenerateHash(string salt, string password);
        Task<UserModel> UpdateOwnProfile(string username, UserUpdateRequest request);
    }
}
