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

namespace CampingNeretva.Service
{
    public class PersonService : BaseCRUDService<PersonModel, PersonSearchObject, Person, PersonInsertRequest, PersonUpdateRequest>, IPersonService
    {

        public PersonService(_200012Context context, IMapper mapper)
        :base(context, mapper){
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

    }
}
