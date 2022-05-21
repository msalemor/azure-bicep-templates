using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

// Add Key vault
var keyvaultName = config["keyvaultName"]; // From App Settings
var credential = new DefaultAzureCredential();
builder.Configuration.AddAzureKeyVault(new Uri($"https://{keyvaultName}.vault.azure.net/"),
    credential
);
// https://fnapp-ecloud-sol5-poc-eus.azurewebsites.net/api/getcontacts
// Add services to the container.
builder.Services.AddHttpClient();
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
