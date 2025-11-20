using CampingNeretva.Model.Models;
using CampingNeretva.Model.Requests;
using CampingNeretva.Model.SearchObjects;

namespace CampingNeretva.Service.Interfaces
{
    public interface IActivityCommentService :
        ICRUDService<ActivityCommentModel, ActivityCommentSearchObject, ActivityCommentInsertRequest, ActivityCommentUpdateRequest>
    {
    }
}
