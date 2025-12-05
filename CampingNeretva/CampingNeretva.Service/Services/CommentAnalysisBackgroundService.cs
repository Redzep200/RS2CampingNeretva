using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CampingNeretva.Service.Services
{
    public class CommentAnalysisBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<CommentAnalysisBackgroundService> _logger;

        public CommentAnalysisBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<CommentAnalysisBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var analysisService = scope.ServiceProvider
                        .GetRequiredService<IActivityCommentAnalysisService>();

                    await analysisService.AnalyzeNewComments();
                    _logger.LogInformation("Comment analysis completed at {time}", DateTime.Now);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error during comment analysis");
                }

                // Run every 6 hours
                await Task.Delay(TimeSpan.FromHours(6), stoppingToken);
            }
        }
    }
}
