using System.Diagnostics;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using webapp.Models;

namespace webapp.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IConfiguration _config;
    private readonly IHttpClientFactory _client;
    private readonly TelemetryClient telemetryClient;

    public HomeController(ILogger<HomeController> logger, IConfiguration configuration, IHttpClientFactory clientFactory, TelemetryClient telemetryClient)
    {
        _logger = logger;
        _config = configuration;
        _client = clientFactory;
        this.telemetryClient = telemetryClient;
    }

    public async Task<IActionResult> Index()
    {
        var customers = new List<Customer>();
        try
        {
            // https://fnapp-contoso-pj2-poc-eus.azurewebsites.net/api/GetContacts
            var uri = _config["funcURI"];// ?? "https://fnapp-ecloud-sol5-poc-eus.azurewebsites.net/api/getcontacts";
            var client = _client.CreateClient();
            customers = await client.GetFromJsonAsync<List<Customer>>(uri);
        }
        catch (System.Exception ex)
        {
            this.telemetryClient.TrackException(ex);
        }
        return View(customers);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
