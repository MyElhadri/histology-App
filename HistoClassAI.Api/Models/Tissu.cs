namespace HistoClassAI.Api.Models;

public class Tissu
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string CodeLabelIa { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Fonctions { get; set; } = string.Empty;

    // Navigation
    public ICollection<Question> Questions { get; set; } = new List<Question>();
    public ICollection<TissuOrgane> TissuOrganes { get; set; } = new List<TissuOrgane>();
    public ICollection<Scan> Scans { get; set; } = new List<Scan>();
}
