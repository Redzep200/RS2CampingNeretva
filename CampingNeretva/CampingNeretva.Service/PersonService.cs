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

        public override PersonModel GetById(int id)
        {
            var model = base.GetById(id);

            if (model != null)
            {
                model.Images = _personImageService.GetImages(id).GetAwaiter().GetResult();
            }

            return model;
        }

        public override PagedResult<PersonModel> GetPaged(PersonSearchObject search)
        {
            var result = base.GetPaged(search);

            foreach (var person in result.ResultList)
            {
                person.Images = _personImageService.GetImages(person.PersonId).GetAwaiter().GetResult();
            }

            return result;
        }

    }
}
