using System.Net.Http.Headers;
using System.Text.Json;

namespace HistoClassAI.Api.Services;

public class IaService : IIaService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<IaService> _logger;

    public IaService(HttpClient httpClient, ILogger<IaService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<(string CodeLabelIa, float Confiance)> PredictAsync(IFormFile image)
    {
        using var content = new MultipartFormDataContent();
        using var stream = image.OpenReadStream();
        var streamContent = new StreamContent(stream);
        streamContent.Headers.ContentType = new MediaTypeHeaderValue(image.ContentType);
        
        content.Add(streamContent, "file", image.FileName);

        var response = await _httpClient.PostAsync("/predict", content);

        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            _logger.LogError("Erreur du service IA ({StatusCode}): {ErrorContent}", response.StatusCode, errorContent);
            
            // On lève une exception personnalisée ou standard qui sera catchée par le contrôleur
            throw new Exception($"Le service IA a retourné une erreur : {response.StatusCode}. Détails : {errorContent}");
        }

        var jsonResponse = await response.Content.ReadAsStringAsync();
        
        using var document = JsonDocument.Parse(jsonResponse);
        var root = document.RootElement;

        var codeLabel = root.GetProperty("code_label_ia").GetString() ?? string.Empty;
        var confiance = root.GetProperty("confiance").GetSingle();

        return (codeLabel, confiance);
    }
}
