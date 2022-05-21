using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;
using System.Net.Http;

namespace ecloud.Function
{

    public class HttpTriggerTest
    {
        private readonly IConfiguration _configuration;

        public HttpTriggerTest(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [FunctionName("HttpTriggerTest")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var SQLPEVerified = false;
            var AppConfigPEVerified = false;
            var LAPEWorkflowVerified = false;

            log.LogInformation("C# HTTP trigger function processed a request.");

            string keyName = "dbconstr";

            // Test connectivity to ASC
            string constr = _configuration[keyName];
            AppConfigPEVerified = true;
            await Task.Delay(1);

            object rows = null;
            try
            {
                // Test connectivity to DB
                using (var sqlConnection = new SqlConnection(constr))
                {
                    await sqlConnection.OpenAsync();
                    using (var cmd = new SqlCommand("select count(*) from [SalesLT].[Customer]", sqlConnection))
                    {
                        rows = await cmd.ExecuteScalarAsync();
                        SQLPEVerified = true;
                    }
                }
            }
            catch (System.Exception ex)
            {
                log.LogError(ex, "Database error");
            }

            try
            {
                var client = new HttpClient();
                var workflow1URI = _configuration["settings:workflow1URI"];
                var res = await client.GetAsync(workflow1URI);
                if (res.IsSuccessStatusCode)
                {
                    log.LogInformation("LA workflow verified");
                    LAPEWorkflowVerified = true;
                }
                else
                {
                    log.LogError($"{res.StatusCode} unable to execute LA workflow");
                }
            }
            catch (System.Exception ex)
            {
                log.LogError(ex, "API Call error");
            }

            return constr != null
                ? (ActionResult)new OkObjectResult($"AppConfig PE {(AppConfigPEVerified ? "Verified" : "failed")}-LA Workflow PE {(LAPEWorkflowVerified ? "Verified" : "failed")}-SQL PE {(SQLPEVerified ? "Verified" : "Failed")} Rows: {rows}")
                : new BadRequestObjectResult($"Please create a key-value with the key '{keyName} {rows}' in App Configuration.");
        }
    }
}
