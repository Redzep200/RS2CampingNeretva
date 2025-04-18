﻿using MapsterMapper;
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
    public class UserTypeService : BaseCRUDService<UserTypeModel, UserTypeSearchObject, UserType, UserTypeUpsertRequest, UserTypeUpsertRequest>, IUserTypeService
    {
        public UserTypeService(_200012Context context, IMapper mapper)
        :base(context, mapper){
        }

        public override IQueryable<UserType> AddFilter(UserTypeSearchObject search, IQueryable<UserType> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeNameGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.TypeName.StartsWith(search.TypeNameGTE));
            }
            
            return filteredQuery;
        }

    }
}
