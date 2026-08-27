using Minio;
using Minio.DataModel.Args;
using Minio.Exceptions;

namespace HistoClassAI.Api.Services;

public class MinioService : IMinioService
{
    private readonly IMinioClient _minioClient;
    private readonly string _bucketName = "histoclass-images";
    private readonly IConfiguration _configuration;

    public MinioService(IMinioClient minioClient, IConfiguration configuration)
    {
        _minioClient = minioClient;
        _configuration = configuration;
    }

    public async Task<string> UploadImageAsync(IFormFile file)
    {
        if (file == null || file.Length == 0)
            throw new ArgumentException("Le fichier est vide.");

        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

        try
        {
            // Vérifier si le bucket existe, sinon il a normalement été créé par minio-init
            bool found = await _minioClient.BucketExistsAsync(new BucketExistsArgs().WithBucket(_bucketName));
            if (!found)
            {
                await _minioClient.MakeBucketAsync(new MakeBucketArgs().WithBucket(_bucketName));
                // Optionnel : Configurer les policies publiques ici si minio-init échoue
            }

            using var stream = file.OpenReadStream();
            await _minioClient.PutObjectAsync(new PutObjectArgs()
                .WithBucket(_bucketName)
                .WithObject(fileName)
                .WithStreamData(stream)
                .WithObjectSize(stream.Length)
                .WithContentType(file.ContentType));

            // URL publique accessible par les clients (Web / Flutter)
            var publicUrl = _configuration["Minio:PublicUrl"] ?? "http://localhost:9000";
            return $"{publicUrl.TrimEnd('/')}/{_bucketName}/{fileName}";
        }
        catch (MinioException e)
        {
            throw new Exception($"Erreur lors de l'upload sur MinIO: {e.Message}");
        }
    }
}
