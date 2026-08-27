namespace HistoClassAI.Api.Models;

public class Organe
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string UrlImage { get; set; } = string.Empty;

    // Navigation
    public ICollection<TissuOrgane> TissuOrganes { get; set; } = new List<TissuOrgane>();
}
