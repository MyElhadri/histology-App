namespace HistoClassAI.Api.DTOs;

public class TissuResponseDto
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Fonctions { get; set; } = string.Empty;
    public string CodeLabelIa { get; set; } = string.Empty;
    
    public List<OrganeDto> Organes { get; set; } = new();
    public int NombreQuestions { get; set; }
}

public class CreateTissuDto
{
    public string Nom { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Fonctions { get; set; } = string.Empty;
    public string CodeLabelIa { get; set; } = string.Empty;
    
    /// <summary>
    /// Liste des IDs d'organes à associer à ce tissu.
    /// </summary>
    public List<Guid> OrganeIds { get; set; } = new();
}
