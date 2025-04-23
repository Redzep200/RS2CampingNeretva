using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;

namespace CampingNeretva.Service
{
    public class RentableItemService : BaseCRUDService<RentableItemModel, RentableItemSearchObject, RentableItem, RentableItemInsertRequest, RentableItemsUpdateRequest>, IRentableItemService
    {
        public RentableItemService(_200012Context context, IMapper mapper)
        :base(context, mapper){
        }

        public override IQueryable<RentableItem> AddFilter(RentableItemSearchObject search, IQueryable<RentableItem> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.StartsWith(search.NameGTE));
            }

            if (search?.PricePerDayGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.PricePerDay == search.PricePerDayGTE);
            }

            return filteredQuery;
        }

        public override void beforeInsert(RentableItemInsertRequest request, RentableItem entity)
        {
            entity.AvailableQuantity = entity.TotalQuantity;
        }

        public override PagedResult<RentableItemModel> GetPaged(RentableItemSearchObject search)
        {
            var result = base.GetPaged(search);

            if (search.DateFrom.HasValue && search.DateTo.HasValue)
            {
                foreach (var item in result.ResultList)
                {
                    var reserved = _context.ReservationRentables
                        .Where(rr =>
                            rr.ItemId == item.ItemId &&
                            rr.Reservation.CheckInDate < search.DateTo &&
                            rr.Reservation.CheckOutDate > search.DateFrom)
                        .Sum(rr => rr.Quantity);

                    item.AvailableQuantity = item.TotalQuantity - reserved;
                }

                result.ResultList = result.ResultList
                    .Where(x => x.AvailableQuantity > 0)
                    .ToList();
            }

            return result;
        }

    }
}
