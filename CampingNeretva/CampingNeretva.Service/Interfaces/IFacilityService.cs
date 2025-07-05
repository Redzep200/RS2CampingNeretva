using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Interfaces
{
    public interface IFacilityService : ICRUDService<FacilityModel, FacilitySearchObject, FacilityInsertRequest, FacilityUpdateRequest>
    {
    }
}
