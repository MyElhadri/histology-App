using HistoClassAI.Api.Models.Enums;

namespace HistoClassAI.Api.Models;

public class Utilisateur
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string MotDePasseHash { get; set; } = string.Empty;
    public RoleUtilisateur Role { get; set; }
    public bool EstActif { get; set; } = true;
    public string? GroupeTp { get; set; }
    public string? Apogee { get; set; }
    public DateTime DateCreation { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<Scan> Scans { get; set; } = new List<Scan>();
    public ICollection<ResultatQCM> ResultatsQCM { get; set; } = new List<ResultatQCM>();
}
