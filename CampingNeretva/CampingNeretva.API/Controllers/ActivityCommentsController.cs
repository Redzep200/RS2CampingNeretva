using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CampingNeretva.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActivityCommentsController : BaseCRUDController<
        ActivityCommentModel,
        ActivityCommentSearchObject,
        ActivityCommentInsertRequest,
        ActivityCommentUpdateRequest>
    {
        public ActivityCommentsController(IActivityCommentService service) : base(service)
        {
        }
    }
}
