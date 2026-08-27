using Microsoft.AspNetCore.Http;

namespace HistoClassAI.Api.Services;

public interface IIaService
{
    /// <summary>
    /// Sends an image to the Python FastAPI microservice and returns the prediction.
    /// </summary>
    Task<(string CodeLabelIa, float Confiance)> PredictAsync(IFormFile image);
}
