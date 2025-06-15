using CampingNeretva.API;
using CampingNeretva.Model.SearchObjects;
using CampingNeretva.Service;
using CampingNeretva.Service.Database;
using CampingNeretva.Service.NotificationService;
using CampingNeretva.Service.ImageServices;
using Mapster;
using MapsterMapper;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Microsoft.Extensions.Logging;

var currentDir = Directory.GetCurrentDirectory();
var envPath = Path.Combine(currentDir, ".env");
Console.WriteLine($"Current directory: {currentDir}");
Console.WriteLine($"Looking for .env at: {envPath}");
Console.WriteLine($".env file exists: {File.Exists(envPath)}");

if (File.Exists(envPath))
{
    try
    {
        Env.Load(envPath);
        Console.WriteLine(".env file loaded successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Failed to load .env file: {ex.Message}");
    }
}
else
{
    Console.WriteLine("Warning: .env file not found. Using default environment variables.");
}

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Services.AddLogging(logging =>
    {
        logging.AddConsole();
        logging.AddDebug();
    });

    builder.Services.AddTransient<IParcelService, ParcelService>();
    builder.Services.AddTransient<ParcelService>();
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
    builder.Services.AddTransient<AccommodationImageService>();
    builder.Services.AddTransient<PersonImageService>();
    builder.Services.AddTransient<VehicleImageService>();
    builder.Services.AddTransient<FacilityImageService>();
    builder.Services.AddTransient<ActivityImageService>();
    builder.Services.AddTransient<ParcelImageService>();
    builder.Services.AddTransient<RentableItemImageService>();
    builder.Services.AddTransient<IReservationService, ReservationService>();
    builder.Services.AddTransient<IParcelAccommodationService, ParcelAccommodationService>();
    builder.Services.AddTransient<IParcelTypeService, ParcelTypeService>();
    builder.Services.AddTransient<IPaymentService, PaymentService>();
    builder.Services.AddSingleton<EmailService>();
    builder.Services.AddHostedService<ReservationNotificationSubscriber>();
    builder.Services.AddScoped<IUserPreferenceService, UserPreferenceService>();
    builder.Services.AddHostedService<RecommendationInitializer>();

    builder.Services.AddHttpClient();

    builder.Services.AddControllers();

    builder.WebHost.ConfigureKestrel(serverOptions =>
    {
        serverOptions.ListenAnyIP(5205);
    });

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme()
        {
            Type = SecuritySchemeType.Http,
            Scheme = "basic"
        });

        c.AddSecurityRequirement(new OpenApiSecurityRequirement()
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "basicAuth" }
                },
                new string[] { }
            }
        });
    });

    var connectionString = builder.Configuration.GetConnectionString("CampingNeretvaConnection");
    if (string.IsNullOrEmpty(connectionString))
    {
        Console.WriteLine("Error: Database connection string is missing.");
        throw new InvalidOperationException("Database connection string is not configured.");
    }
    builder.Services.AddDbContext<_200012Context>(options => options.UseSqlServer(connectionString));

    builder.Services.AddMapster();
    builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    builder.Configuration.AddEnvironmentVariables();
    builder.Services.Configure<CampingNeretva.Model.emailHelpers.EmailSettings>(options =>
    {
        options.SmtpHost = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
        options.SmtpPort = int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out int port) ? port : 587;
        options.SmtpUser = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "redzepcamping@gmail.com";
        options.SmtpPass = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "nxpv easm cjfs bfvw";
    });

    var app = builder.Build();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseCors("AllowAll");
    app.UseAuthorization();
    app.MapControllers();
    app.UseStaticFiles();

    Console.WriteLine("Starting application...");
    app.Run();
}
catch (Exception ex)
{
    Console.WriteLine($"Application failed to start: {ex.Message}\nStack Trace: {ex.StackTrace}");
    throw;
}