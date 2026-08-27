namespace HistoClassAI.Api.DTOs;

public class ScanResultDto
{
    public Guid ScanId { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string CodeLabelIa { get; set; } = string.Empty;
    public float Confiance { get; set; }
    
    // Détails du tissu trouvé
    public Guid TissuId { get; set; }
    public string NomTissu { get; set; } = string.Empty;
    public string DescriptionTissu { get; set; } = string.Empty;
    
    // Organes liés
    public List<OrganeDto> Organes { get; set; } = new();

    // QCM généré
    public List<QuestionDto> Questions { get; set; } = new();
}

public class OrganeDto
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
}

public class QuestionDto
{
    public Guid Id { get; set; }
    public string Texte { get; set; } = string.Empty;
    public List<ChoixDto> Choix { get; set; } = new();
}

public class ChoixDto
{
    public Guid Id { get; set; }
    public string Texte { get; set; } = string.Empty;
    public bool EstCorrect { get; set; }
}
