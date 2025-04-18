using CampingNeretva.API;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using CampingNeretva.Service.Database;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IParcelService>(provider =>
    new ParcelService(
        provider.GetRequiredService<_200012Context>(),
        provider.GetRequiredService<IMapper>(),
        provider.GetRequiredService<IImageService>()
    )
);
builder.Services.AddTransient<IActivityService, ActivityService>();
builder.Services.AddTransient<IAccommodationService, AccommodationService>();
builder.Services.AddTransient<IPersonService, PersonService>();
builder.Services.AddTransient<IRentableItemService, RentableItemService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IVehicleService, VehicleService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IWorkerService, WorkerService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IUserTypeService, UserTypeService>();
builder.Services.AddTransient<IFacilityService, FacilityService>();
builder.Services.AddTransient<IImageService, ImageService>();

builder.Services.AddControllers();

builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.ListenAnyIP(5205); // Allows connections from emulator
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{ Type = ReferenceType.SecurityScheme, Id = "basicAuth" }
            },
            new string []{}
        }
    });
});

var connectionString = builder.Configuration.GetConnectionString("CampingNeretvaConnection");
builder.Services.AddDbContext<_200012Context>(options => options.UseSqlServer(connectionString));

builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.UseStaticFiles();

app.Run();
