namespace HistoClassAI.Api.Models;

public class Scan
{
    public Guid Id { get; set; }

    public Guid UtilisateurId { get; set; }
    public Utilisateur Utilisateur { get; set; } = null!;

    public Guid TissuId { get; set; }
    public Tissu Tissu { get; set; } = null!;

    public string UrlImage { get; set; } = string.Empty;
    public float ScoreConfiance { get; set; }
    public DateTime DateScan { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<ResultatQCM> ResultatsQCM { get; set; } = new List<ResultatQCM>();
}
