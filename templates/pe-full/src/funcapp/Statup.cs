using System;
using Azure.Identity;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(ecloud.Function.Startup))]

namespace ecloud.Function
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            string cs = Environment.GetEnvironmentVariable("ConnectionString");
            //builder.ConfigurationBuilder.AddAzureAppConfiguration(cs);
            builder.ConfigurationBuilder.AddAzureAppConfiguration(options =>
            {
                options.Connect(cs)
                .ConfigureKeyVault(kv => kv.SetCredential(new DefaultAzureCredential()));
            });
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
        }
    }
}