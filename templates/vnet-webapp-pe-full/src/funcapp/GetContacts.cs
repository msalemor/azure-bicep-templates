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
using System.Collections.Generic;
using System.Linq;
using ecloud.Function.Models;

namespace ecloud.Function
{

    public class GetContacts
    {
        private readonly IConfiguration _configuration;

        public GetContacts(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [FunctionName("GetContacts")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            const string keyName = "settings:dbconstr";
            string constr = _configuration[keyName];
            var customers = new List<Customer>();

            // https://fnapp-ecloud-sol5-poc-eus.azurewebsites.net/api/GetContacts

            try
            {
                // Test connectivity to DB
                using (var sqlConnection = new SqlConnection(constr))
                {
                    await sqlConnection.OpenAsync();
                    using (var cmd = new SqlCommand("SELECT TOP (100) CustomerId,FirstName,LastName,EmailAddress,Phone FROM [SalesLT].[Customer]", sqlConnection))
                    {
                        using (var reader = await cmd.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                customers.Add(new Customer
                                {
                                    CustomerId = (int)reader[0],
                                    FirstName = reader[1].ToString(),
                                    LastName = reader[2].ToString(),
                                    EmailAddress = reader[3].ToString(),
                                    Phone = reader[4].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                log.LogError(ex, "Database error");
            }

            return customers.Any()
                ? (ActionResult)new JsonResult(customers)
                : new BadRequestObjectResult("No records found.");
        }
    }

}
