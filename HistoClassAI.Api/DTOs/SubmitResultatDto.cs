namespace HistoClassAI.Api.DTOs;

public class SubmitResultatDto
{
    public Guid ScanId { get; set; }
    public int Note { get; set; }
}

public class ResultatResponseDto
{
    public Guid Id { get; set; }
    public Guid ScanId { get; set; }
    public string TissuNom { get; set; } = string.Empty;
    public int Note { get; set; }
    public DateTime DateTest { get; set; }
}
