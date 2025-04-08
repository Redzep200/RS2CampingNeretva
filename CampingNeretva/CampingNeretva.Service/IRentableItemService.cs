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
    public interface IRentableItemService : ICRUDService<RentableItemModel, RentableItemSearchObject, RentableItemInsertRequest, RentableItemsUpdateRequest>
    {
    }
}
