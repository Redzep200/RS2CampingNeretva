﻿using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CampingNeretva.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.Models;
using CampingNeretva.Service.Interfaces;

namespace CampingNeretva.Service.Services
{
    public class ReviewService : BaseCRUDService<ReviewModel, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(_200012Context context, IMapper mapper)
        : base(context, mapper)
        {
        }

        public override IQueryable<Review> AddFilter(ReviewSearchObject search, IQueryable<Review> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search?.ReviewIdGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.ReviewId == search.ReviewIdGTE);
            }

            if (search?.DatePostedGTE.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.DatePosted == search.DatePostedGTE);
            }

            if (search?.IsUserIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.User).ThenInclude(u => u.UserType);
            }

            if (search?.IsWorkerIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Worker).ThenInclude(r => r.Roles);
            }

            if (search?.WorkerId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.WorkerId == search.WorkerId);
            }

            if (search?.UserId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.UserId == search.UserId);
            }

            return filteredQuery;
        }

        public override void beforeInsert(ReviewInsertRequest request, Review entity)
        {
            entity.DatePosted = DateTime.Now;
            var user = _context.Users.FirstOrDefault(x => x.UserId == request.UserId);
            if (user != null)
            {
                entity.User = user;
            }

            var worker = _context.Workers.FirstOrDefault(x => x.WorkerId == request.WorkerId);
            if (worker != null)
            {
                entity.Worker = worker;
            }
        }


    }
}
