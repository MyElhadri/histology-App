namespace HistoClassAI.Api.Models;

public class ResultatQCM
{
    public Guid Id { get; set; }

    public Guid UtilisateurId { get; set; }
    public Utilisateur Utilisateur { get; set; } = null!;

    public Guid ScanId { get; set; }
    public Scan Scan { get; set; } = null!;

    public int Note { get; set; }
    public DateTime DateTest { get; set; } = DateTime.UtcNow;
}
