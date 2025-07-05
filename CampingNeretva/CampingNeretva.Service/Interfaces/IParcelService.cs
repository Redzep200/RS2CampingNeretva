using CampingNeretva.Model.DTO;
using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.AccessControl;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Interfaces
{
    public interface IParcelService : ICRUDService<ParcelModel, ParcelSearchObject, ParcelInsertRequest, ParcelUpdateRequest>
    {
        Task<List<UnavailableParcelModel>> GetUnavailableParcels(DateTime dateFrom, DateTime dateTo);
    }
}
