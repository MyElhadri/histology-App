namespace HistoClassAI.Api.Models;

public class Question
{
    public Guid Id { get; set; }

    public Guid TissuId { get; set; }
    public Tissu Tissu { get; set; } = null!;

    public string Texte { get; set; } = string.Empty;

    // Navigation
    public ICollection<Choix> Choix { get; set; } = new List<Choix>();
}
