using CampingNeretva.Model;
using CampingNeretva.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.AccessControl;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IParcelService
    {
        List<ParcelModel> GetList(ParcelSearchObject searchObject);
    }
}
