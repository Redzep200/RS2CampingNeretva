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
using CampingNeretva.Service.ImageServices;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service
{

    public class PersonService : BaseCRUDService<PersonModel, PersonSearchObject, Person, PersonInsertRequest, PersonUpdateRequest>, IPersonService
    {
        private readonly PersonImageService _personImageService;

        public PersonService(_200012Context context, IMapper mapper, PersonImageService personImageService)
        : base(context, mapper)
        {
            _personImageService = personImageService;
        }

        public override IQueryable<Person> AddFilter(PersonSearchObject search, IQueryable<Person> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Type.StartsWith(search.TypeGTE));
            }

            if (search?.PricePerNightGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.PricePerNight == search.PricePerNightGTE);
            }

            return filteredQuery;
        }

        public override async Task<PersonModel> GetById(int id)
        {
            var model = await base.GetById(id);

            if (model != null)
            {
                model.Images = await _personImageService.GetImages(id);
            }

            return model;
        }

        public override async Task<PagedResult<PersonModel>> GetPaged(PersonSearchObject search)
        {
            var result = await base.GetPaged(search);

            foreach (var person in result.ResultList)
            {
                person.Images = await _personImageService.GetImages(person.PersonId);
            }

            return result;
        }


        public override async Task Delete(int id)
        {
            var person = await _context.Persons.FindAsync(id);
            if (person == null)
            {
                throw new Exception("Person not found");
            }

            var relatedReservations = await _context.ReservationPersons
                                      .Where(x => x.PersonId == id)
                                      .ToListAsync();
            _context.ReservationPersons.RemoveRange(relatedReservations);

            var personImages = await _context.PersonImages.Where(x => x.PersonId == id).ToListAsync();
            _context.PersonImages.RemoveRange(personImages);

            _context.Persons.Remove(person);
            _context.SaveChanges();
        }

        public override async Task<PersonModel> Insert(PersonInsertRequest request)
        {
            var entity = await base.Insert(request);
            var imageId = request.ImageId;

            _context.PersonImages.Add(new PersonImage
            {
                PersonId = entity.PersonId,
                ImageId = imageId
            });

            await _context.SaveChangesAsync();
            return await GetById(entity.PersonId);
        }

        public override async Task<PersonModel> Update(int id, PersonUpdateRequest request)
        {
            var entity = await base.Update(id, request);

            if (request.ImageId.HasValue && request.ImageId.Value > 0)
            {
                var existingLinks = await _context.PersonImages.Where(x => x.PersonId == id).ToListAsync();
                _context.PersonImages.RemoveRange(existingLinks);

                _context.PersonImages.Add(new PersonImage
                {
                    PersonId = id,
                    ImageId = request.ImageId.Value
                });
            }
            await _context.SaveChangesAsync();

            return await GetById(id);
        }
    }
}
