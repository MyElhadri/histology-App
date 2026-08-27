using Microsoft.AspNetCore.Http;

namespace HistoClassAI.Api.Services;

public interface IMinioService
{
    /// <summary>
    /// Uploads an image to MinIO and returns the public URL.
    /// </summary>
    Task<string> UploadImageAsync(IFormFile file);
}
