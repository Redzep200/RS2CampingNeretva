﻿using CampingNeretva.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service
{
    public interface IPersonService
    {
        List<PersonModel> GetList();
    }
}
