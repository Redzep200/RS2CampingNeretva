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
using CampingNeretva.Service.ImageServices;
using System.Diagnostics.CodeAnalysis;

namespace CampingNeretva.Service
{
    public class RentableItemService : BaseCRUDService<RentableItemModel, RentableItemSearchObject, RentableItem, RentableItemInsertRequest, RentableItemsUpdateRequest>, IRentableItemService
    {
        private readonly RentableItemImageService _rentableItemImageService;

        public RentableItemService(_200012Context context, IMapper mapper, RentableItemImageService rentableItemImageService)
        :base(context, mapper){
            _rentableItemImageService = rentableItemImageService;
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

        public override async Task<PagedResult<RentableItemModel>> GetPaged(RentableItemSearchObject search)
        {
            var result = await base.GetPaged(search);

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

                // Remove fully booked items
                result.ResultList = result.ResultList
                    .Where(x => x.AvailableQuantity > 0)
                    .ToList();
            }
            else
            {
                foreach (var item in result.ResultList)
                {
                    item.AvailableQuantity = item.TotalQuantity;
                }
            }


            foreach (var item in result.ResultList)
            {
                item.Images = await _rentableItemImageService.GetImages(item.ItemId);
            }

            return result;
        }


       public async Task<List<RentableItemModel>> GetAvailableAsync(DateTime from, DateTime until)
{
    // Get reserved quantities in the selected range
    var reservedQuantities = await _context.ReservationRentables
        .Where(r =>
            r.Reservation.CheckInDate < until &&
            r.Reservation.CheckOutDate > from)
        .GroupBy(r => r.ItemId)
        .Select(g => new
        {
            RentableItemId = g.Key,
            ReservedQuantity = g.Sum(r => r.Quantity)
        })
        .ToDictionaryAsync(x => x.RentableItemId, x => x.ReservedQuantity);

    // Load all items with images
    var items = await _context.RentableItems
        .Include(x => x.RentableItemImages)
        .ToListAsync();

    var models = new List<RentableItemModel>();

    foreach (var item in items)
    {
        var reserved = reservedQuantities.TryGetValue(item.ItemId, out var q) ? q : 0;
        var availableQuantity = item.TotalQuantity - reserved;

        if (availableQuantity > 0)
        {
            var model = Mapper.Map<RentableItemModel>(item);
            model.AvailableQuantity = availableQuantity;
            model.Images = await _rentableItemImageService.GetImages(item.ItemId); // async call
            models.Add(model);
        }
    }

    return models;
}



        public override async Task<RentableItemModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _rentableItemImageService.GetImages(id);
            }

            return model;
        }

        public override async Task Delete(int id)
        {
            var item = await _context.RentableItems.FindAsync(id);
            if (item == null)
            {
                throw new Exception("Rentable item not found");
            }

            var relatedReservations = await _context.ReservationRentables.Where(x => x.ItemId == id).ToListAsync();
            _context.ReservationRentables.RemoveRange(relatedReservations);

            var itemImages = await _context.RentableItemImages.Where(x => x.RentableItemId == id).ToListAsync();
            _context.RentableItemImages.RemoveRange(itemImages);

            _context.RentableItems.Remove(item);
            await _context.SaveChangesAsync();
        }

        public override async Task<RentableItemModel> Insert(RentableItemInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.RentableItemImages.Add(new RentableItemImage
            {
                RentableItemId = entity.ItemId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.ItemId);
        }

        public override async Task<RentableItemModel> Update(int id, RentableItemsUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            var existingLinks = await _context.RentableItemImages.Where(x => x.RentableItemId == id).ToListAsync();
            _context.RentableItemImages.RemoveRange(existingLinks);

            if (request.ImageId.HasValue)
            {
                _context.RentableItemImages.Add(new RentableItemImage
                {
                    RentableItemId = id,
                    ImageId = request.ImageId.Value
                });
            }

            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }
}
