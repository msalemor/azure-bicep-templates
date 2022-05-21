using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using webapp.Models;

namespace webapp.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IConfiguration _config;
    private readonly IHttpClientFactory _client;

    public HomeController(ILogger<HomeController> logger, IConfiguration configuration, IHttpClientFactory clientFactory)
    {
        _logger = logger;
        _config = configuration;
        _client = clientFactory;
    }

    public async Task<IActionResult> Index()
    {
        var customers = new List<Customer>();
        var uri = _config["funcURI"];// ?? "https://fnapp-ecloud-sol5-poc-eus.azurewebsites.net/api/getcontacts";
        var client = _client.CreateClient();
        customers = await client.GetFromJsonAsync<List<Customer>>(uri);
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
