using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Mapster;

namespace CampingNeretva.Service
{
    public class UserService : BaseCRUDService<UserModel, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {

        public UserService(_200012Context context, IMapper mapper)
        :base(context, mapper){
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
                filteredQuery = filteredQuery.Where(x => x.UserName.Equals(search.UserName));
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

        public override void beforeInsert(UserInsertRequest request, User entity)
        {
            var userType = _context.UserTypes.FirstOrDefault(x => x.TypeName == "Guest");
            if(userType != null)
            {
                entity.UserType = userType;
            }
            else
            {
                throw new Exception("Role *Guest* has been removed");
            }

            if(request.Password != request.PasswordConfirmation)
            {
                throw new Exception("Password and PasswordConfirmation are different");
            }
            else
            {
                entity.PasswordSalt = GenerateSalt();
                entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
            }

        }

        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);

            return Convert.ToBase64String(byteArray);
        }

        public string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public UserModel Login(string username, string password)
        {
            var entity = _context.Users.Include(x=> x.UserType).FirstOrDefault(x => x.UserName == username);

            if(entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.PasswordSalt, password);

            if(hash != entity.PasswordHash)
            {
                return null;
            }

            return this.Mapper.Map<UserModel>(entity);
        }
    }
}
