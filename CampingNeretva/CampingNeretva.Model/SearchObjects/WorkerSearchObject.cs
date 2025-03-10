﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CampingNeretva.Model.SearchObjects
{
    public class WorkerSearchObject
    {
        public string? FirstNameGTE { get; set; }
        public string? LastNameGTE { get; set; }
        public bool? IsWorkerRoleIncluded { get; set; }
        public int? Page { get; set; }
        public int? PageSize { get; set; }
    }
}
