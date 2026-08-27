using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace HistoClassAI.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(ApplicationDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponseDto>> Login([FromBody] LoginRequestDto request)
    {
        var utilisateur = await _context.Utilisateurs
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (utilisateur == null)
        {
            return Unauthorized("Email ou mot de passe incorrect.");
        }

        if (!utilisateur.EstActif)
        {
            return Unauthorized("Votre compte a été désactivé. Veuillez contacter votre professeur.");
        }

        // Vérification du mot de passe avec BCrypt
        if (!BCrypt.Net.BCrypt.Verify(request.MotDePasse, utilisateur.MotDePasseHash))
        {
            return Unauthorized("Email ou mot de passe incorrect.");
        }

        var token = GenerateJwtToken(utilisateur);

        return Ok(new LoginResponseDto
        {
            Token = token,
            UtilisateurId = utilisateur.Id,
            Role = utilisateur.Role
        });
    }

    private string GenerateJwtToken(Models.Utilisateur utilisateur)
    {
        var jwtSection = _configuration.GetSection("Jwt");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, utilisateur.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, utilisateur.Email),
            new Claim(ClaimTypes.Role, utilisateur.Role.ToString()),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: jwtSection["Issuer"],
            audience: jwtSection["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(2), // Token valide 2 heures
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
