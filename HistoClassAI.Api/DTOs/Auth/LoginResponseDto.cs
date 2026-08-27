using HistoClassAI.Api.Models.Enums;

namespace HistoClassAI.Api.DTOs.Auth;

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public Guid UtilisateurId { get; set; }
    public RoleUtilisateur Role { get; set; }
}
