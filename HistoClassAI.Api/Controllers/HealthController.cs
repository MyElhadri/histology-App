using Microsoft.AspNetCore.Mvc;
using Minio;
using Minio.DataModel.Args;
using Npgsql;

namespace HistoClassAI.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public HealthController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public async Task<IActionResult> Check()
    {
        var dbStatus = "Disconnected";
        var storageStatus = "Disconnected";

        // ── Test PostgreSQL ──────────────────────────────────────────
        try
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            await using var connection = new NpgsqlConnection(connectionString);
            await connection.OpenAsync();

            await using var cmd = new NpgsqlCommand("SELECT 1", connection);
            await cmd.ExecuteScalarAsync();

            dbStatus = "Connected";
        }
        catch (Exception ex)
        {
            dbStatus = $"Error: {ex.Message}";
        }

        // ── Test MinIO ───────────────────────────────────────────────
        try
        {
            var minioSection = _configuration.GetSection("Minio");

            var minioClient = new MinioClient()
                .WithEndpoint(minioSection["Endpoint"])
                .WithCredentials(minioSection["AccessKey"], minioSection["SecretKey"]);

            if (!bool.Parse(minioSection["SSL"] ?? "false"))
            {
                // HTTP (pas HTTPS)
            }
            else
            {
                minioClient = minioClient.WithSSL();
            }

            var client = minioClient.Build();

            var bucketExists = await client.BucketExistsAsync(
                new BucketExistsArgs().WithBucket("histoclass-images")
            );

            storageStatus = bucketExists ? "Connected" : "Bucket not found";
        }
        catch (Exception ex)
        {
            storageStatus = $"Error: {ex.Message}";
        }

        // ── Réponse ──────────────────────────────────────────────────
        var isHealthy = dbStatus == "Connected" && storageStatus == "Connected";

        return isHealthy
            ? Ok(new { database = dbStatus, storage = storageStatus })
            : StatusCode(503, new { database = dbStatus, storage = storageStatus });
    }
}
