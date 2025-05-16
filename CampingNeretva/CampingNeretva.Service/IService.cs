using CampingNeretva.Model;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        Task<PagedResult<TModel>> GetPaged(TSearch search);
        Task<TModel> GetById(int id);
    }
}
