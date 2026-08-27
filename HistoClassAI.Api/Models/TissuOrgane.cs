namespace HistoClassAI.Api.Models;

public class TissuOrgane
{
    public Guid TissuId { get; set; }
    public Tissu Tissu { get; set; } = null!;

    public Guid OrganeId { get; set; }
    public Organe Organe { get; set; } = null!;
}
