using MapsterMapper;
using CampingNeretva.Model;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public class PersonService : IPersonService
    {
        public CampingNeretvaRs2Context _context { get; set; }
        public IMapper Mapper { get; set; }

        public PersonService(CampingNeretvaRs2Context context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public virtual List<PersonModel> GetList()
        {
            List<PersonModel> result = new List<PersonModel>();

            var list = _context.Persons.ToList();
            result = Mapper.Map(list, result);
            return result;
        }

    }
}
