namespace HistoClassAI.Api.Models;

public class Choix
{
    public Guid Id { get; set; }

    public Guid QuestionId { get; set; }
    public Question Question { get; set; } = null!;

    public string Texte { get; set; } = string.Empty;
    public bool EstCorrect { get; set; }
}
