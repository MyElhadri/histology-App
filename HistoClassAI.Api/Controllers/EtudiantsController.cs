using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs;
using HistoClassAI.Api.Models.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Text;

namespace HistoClassAI.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = "Professeur")]
public class EtudiantsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly HistoClassAI.Api.Services.IEmailService _emailService;
    private readonly ILogger<EtudiantsController> _logger;

    public EtudiantsController(
        ApplicationDbContext context, 
        HistoClassAI.Api.Services.IEmailService emailService,
        ILogger<EtudiantsController> logger)
    {
        _context = context;
        _emailService = emailService;
        _logger = logger;
    }

    private static string NormalizeForEmail(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return "";
        var normalized = text.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();
        foreach (var c in normalized)
        {
            var uc = CharUnicodeInfo.GetUnicodeCategory(c);
            if (uc != UnicodeCategory.NonSpacingMark && (char.IsLetterOrDigit(c) || c == '.' || c == '-' || c == '_'))
            {
                sb.Append(c);
            }
        }
        return sb.ToString().ToLowerInvariant();
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<EtudiantResponseDto>>> GetEtudiants()
    {
        var etudiants = await _context.Utilisateurs
            .Where(u => u.Role == RoleUtilisateur.Etudiant)
            .OrderByDescending(u => u.DateCreation)
            .Select(u => new EtudiantResponseDto
            {
                Id = u.Id,
                Nom = u.Nom,
                Prenom = u.Prenom,
                Email = u.Email,
                EstActif = u.EstActif,
                DateCreation = u.DateCreation
            })
            .ToListAsync();

        return Ok(etudiants);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateEtudiant(Guid id, UpdateEtudiantDto dto)
    {
        var etudiant = await _context.Utilisateurs.FirstOrDefaultAsync(u => u.Id == id && u.Role == RoleUtilisateur.Etudiant);
        if (etudiant == null)
        {
            return NotFound("Étudiant introuvable.");
        }

        if (string.IsNullOrWhiteSpace(dto.Nom) || string.IsNullOrWhiteSpace(dto.Prenom) || string.IsNullOrWhiteSpace(dto.Email))
        {
            return BadRequest("Tous les champs (Nom, Prénom, Email) sont obligatoires.");
        }

        var newEmail = dto.Email.Trim().Trim('.', ' ').ToLowerInvariant();
        if (newEmail != etudiant.Email.ToLowerInvariant() && await _context.Utilisateurs.AnyAsync(u => u.Email == newEmail && u.Id != id))
        {
            return BadRequest($"L'adresse email {newEmail} est déjà utilisée par un autre compte.");
        }

        etudiant.Nom = dto.Nom.Trim();
        etudiant.Prenom = dto.Prenom.Trim();
        etudiant.Email = newEmail;
        etudiant.EstActif = dto.EstActif;

        await _context.SaveChangesAsync();

        return Ok(new EtudiantResponseDto
        {
            Id = etudiant.Id,
            Nom = etudiant.Nom,
            Prenom = etudiant.Prenom,
            Email = etudiant.Email,
            EstActif = etudiant.EstActif,
            DateCreation = etudiant.DateCreation
        });
    }

    [HttpPatch("{id}/toggle-actif")]
    public async Task<IActionResult> ToggleActifEtudiant(Guid id)
    {
        var etudiant = await _context.Utilisateurs.FirstOrDefaultAsync(u => u.Id == id && u.Role == RoleUtilisateur.Etudiant);
        if (etudiant == null)
        {
            return NotFound("Étudiant introuvable.");
        }

        etudiant.EstActif = !etudiant.EstActif;
        await _context.SaveChangesAsync();

        return Ok(new { id = etudiant.Id, estActif = etudiant.EstActif, message = etudiant.EstActif ? "Compte étudiant activé." : "Compte étudiant désactivé." });
    }

    [HttpPost("{id}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, [FromBody] ResetPasswordDto dto)
    {
        var etudiant = await _context.Utilisateurs.FirstOrDefaultAsync(u => u.Id == id && u.Role == RoleUtilisateur.Etudiant);
        if (etudiant == null)
        {
            return NotFound("Étudiant introuvable.");
        }

        string newPassword;
        if (!string.IsNullOrWhiteSpace(dto.NouveauMotDePasse))
        {
            newPassword = dto.NouveauMotDePasse.Trim();
        }
        else
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
            var random = new Random();
            newPassword = new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());
        }

        etudiant.MotDePasseHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        await _context.SaveChangesAsync();

        bool emailSent = false;
        if (dto.EnvoyerEmail)
        {
            var subject = "Réinitialisation de votre mot de passe HistoClassAI";
            var body = $@"
                <div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;"">
                    <h2 style=""color: #4F46E5;"">Mise à jour de mot de passe, {etudiant.Prenom} !</h2>
                    <p>Votre mot de passe a été réinitialisé par votre professeur.</p>
                    <div style=""background: #f8fafc; padding: 16px; border-radius: 6px; border-left: 4px solid #4F46E5; margin: 16px 0;"">
                        <p style=""margin: 4px 0;""><strong>Email :</strong> {etudiant.Email}</p>
                        <p style=""margin: 4px 0;""><strong>Nouveau mot de passe :</strong> <span style=""color: #4F46E5; font-family: monospace; font-size: 16px; font-weight: bold;"">{newPassword}</span></p>
                    </div>
                    <p>Utilisez ces identifiants pour vous connecter sur l'application mobile HistoClassAI.</p>
                </div>
            ";
            try
            {
                await _emailService.SendEmailAsync(etudiant.Email, subject, body);
                emailSent = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erreur d'envoi du mail de réinitialisation à {Email}", etudiant.Email);
            }
        }

        return Ok(new
        {
            id = etudiant.Id,
            email = etudiant.Email,
            nouveauMotDePasse = newPassword,
            emailEnvoye = emailSent
        });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteEtudiant(Guid id)
    {
        var etudiant = await _context.Utilisateurs.FirstOrDefaultAsync(u => u.Id == id && u.Role == RoleUtilisateur.Etudiant);
        if (etudiant == null)
        {
            return NotFound("Étudiant introuvable.");
        }

        // Supprimer les scans et résultats de l'étudiant
        var scans = await _context.Scans.Where(s => s.UtilisateurId == id).ToListAsync();
        _context.Scans.RemoveRange(scans);

        var resultats = await _context.ResultatsQCM.Where(r => r.UtilisateurId == id).ToListAsync();
        _context.ResultatsQCM.RemoveRange(resultats);

        _context.Utilisateurs.Remove(etudiant);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Étudiant et ses données associées supprimés avec succès." });
    }

    [HttpPost]
    public async Task<ActionResult<EtudiantResponseDto>> AddEtudiant(AddEtudiantDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Nom) || string.IsNullOrWhiteSpace(dto.Prenom))
        {
            return BadRequest("Tous les champs (Nom, Prénom) sont obligatoires.");
        }

        string email;
        if (!string.IsNullOrWhiteSpace(dto.Email) && dto.Email.Contains("@"))
        {
            var cleanEmail = dto.Email.Trim().Trim('.', ' ').ToLowerInvariant();
            var parts = cleanEmail.Split('@');
            var localPart = parts[0].Trim('.', ' ');
            var domainPart = parts[1].Trim('.', ' ');
            email = $"{localPart}@{domainPart}";

            if (await _context.Utilisateurs.AnyAsync(u => u.Email == email))
            {
                return BadRequest($"Un utilisateur avec l'adresse email {email} existe déjà.");
            }
        }
        else
        {
            var p = NormalizeForEmail(dto.Prenom);
            var n = NormalizeForEmail(dto.Nom);
            string localPart;
            if (!string.IsNullOrEmpty(p) && !string.IsNullOrEmpty(n))
                localPart = $"{p}.{n}";
            else if (!string.IsNullOrEmpty(p))
                localPart = p;
            else
                localPart = n;

            localPart = localPart.Trim('.', ' ');

            var emailBase = $"{localPart}@etu.uae.ac.ma";
            email = emailBase;
            int index = 1;
            while (await _context.Utilisateurs.AnyAsync(u => u.Email == email))
            {
                email = $"{localPart}{index}@etu.uae.ac.ma";
                index++;
            }
        }

        // Generate an 8 character random password
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        var random = new Random();
        var password = new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());

        var etudiant = new Models.Utilisateur
        {
            Id = Guid.NewGuid(),
            Nom = dto.Nom.Trim(),
            Prenom = dto.Prenom.Trim(),
            Email = email,
            MotDePasseHash = BCrypt.Net.BCrypt.HashPassword(password),
            Role = RoleUtilisateur.Etudiant,
            DateCreation = DateTime.UtcNow
        };

        _context.Utilisateurs.Add(etudiant);
        await _context.SaveChangesAsync();

        // Envoi de l'email réel
        var subject = "Vos identifiants HistoClassAI";
        var body = $@"
            <div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;"">
                <h2 style=""color: #4F46E5;"">Bienvenue sur HistoClassAI, {etudiant.Prenom} !</h2>
                <p>Votre compte étudiant a été créé par votre professeur.</p>
                <p>Voici vos identifiants pour vous connecter sur l'application mobile :</p>
                <div style=""background: #f8fafc; padding: 16px; border-radius: 6px; border-left: 4px solid #4F46E5; margin: 16px 0;"">
                    <p style=""margin: 4px 0;""><strong>Email :</strong> <span style=""color: #1e293b;"">{etudiant.Email}</span></p>
                    <p style=""margin: 4px 0;""><strong>Mot de passe :</strong> <span style=""color: #4F46E5; font-family: monospace; font-size: 16px; font-weight: bold;"">{password}</span></p>
                </div>
                <p>Téléchargez l'application mobile <strong>HistoClassAI</strong> sur votre téléphone pour commencer à analyser des lames histologiques.</p>
                <hr style=""border: none; border-top: 1px solid #eeeeee; margin: 20px 0;"" />
                <p style=""font-size: 12px; color: #64748b;"">Cet email a été envoyé automatiquement par la plateforme HistoClassAI.</p>
            </div>
        ";

        bool emailSent = false;
        try 
        {
            await _emailService.SendEmailAsync(etudiant.Email, subject, body);
            emailSent = true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Échec de l'envoi de l'email à {Email}", etudiant.Email);
        }

        var responseDto = new EtudiantResponseDto
        {
            Id = etudiant.Id,
            Nom = etudiant.Nom,
            Prenom = etudiant.Prenom,
            Email = etudiant.Email,
            MotDePasseGenere = password,
            EmailEnvoye = emailSent,
            DateCreation = etudiant.DateCreation
        };

        return CreatedAtAction(nameof(GetEtudiants), new { id = etudiant.Id }, responseDto);
    }

    [HttpPost("import")]
    public async Task<IActionResult> ImportEtudiants(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("Le fichier est invalide ou vide.");
        }

        var importedCount = 0;
        var emailSentCount = 0;
        using var reader = new StreamReader(file.OpenReadStream());
        
        while (!reader.EndOfStream)
        {
            var line = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(line)) continue;

            var parts = line.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 2) continue;

            var nom = parts[0].Trim();
            var prenom = parts[1].Trim();
            string email;

            if (parts.Length >= 3 && parts[2].Contains("@"))
            {
                var cleanEmail = parts[2].Trim().Trim('.', ' ').ToLowerInvariant();
                var emailParts = cleanEmail.Split('@');
                var localPart = emailParts[0].Trim('.', ' ');
                var domainPart = emailParts[1].Trim('.', ' ');
                email = $"{localPart}@{domainPart}";
            }
            else
            {
                var p = NormalizeForEmail(prenom);
                var n = NormalizeForEmail(nom);
                string localPart;
                if (!string.IsNullOrEmpty(p) && !string.IsNullOrEmpty(n))
                    localPart = $"{p}.{n}";
                else if (!string.IsNullOrEmpty(p))
                    localPart = p;
                else
                    localPart = n;

                localPart = localPart.Trim('.', ' ');

                var emailBase = $"{localPart}@etu.uae.ac.ma";
                email = emailBase;
                int index = 1;
                while (await _context.Utilisateurs.AnyAsync(u => u.Email == email))
                {
                    email = $"{localPart}{index}@etu.uae.ac.ma";
                    index++;
                }
            }

            if (await _context.Utilisateurs.AnyAsync(u => u.Email == email))
            {
                continue; // Sauter si l'email existe déjà
            }

            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
            var random = new Random();
            var password = new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());

            var etudiant = new Models.Utilisateur
            {
                Id = Guid.NewGuid(),
                Nom = nom,
                Prenom = prenom,
                Email = email,
                MotDePasseHash = BCrypt.Net.BCrypt.HashPassword(password),
                Role = RoleUtilisateur.Etudiant,
                DateCreation = DateTime.UtcNow
            };

            _context.Utilisateurs.Add(etudiant);
            await _context.SaveChangesAsync();
            importedCount++;

            var subject = "Vos identifiants HistoClassAI";
            var body = $@"
                <div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;"">
                    <h2 style=""color: #4F46E5;"">Bienvenue sur HistoClassAI, {etudiant.Prenom} !</h2>
                    <p>Votre compte étudiant a été créé par votre professeur.</p>
                    <p>Voici vos identifiants pour vous connecter sur l'application mobile :</p>
                    <div style=""background: #f8fafc; padding: 16px; border-radius: 6px; border-left: 4px solid #4F46E5; margin: 16px 0;"">
                        <p style=""margin: 4px 0;""><strong>Email :</strong> <span style=""color: #1e293b;"">{etudiant.Email}</span></p>
                        <p style=""margin: 4px 0;""><strong>Mot de passe :</strong> <span style=""color: #4F46E5; font-family: monospace; font-size: 16px; font-weight: bold;"">{password}</span></p>
                    </div>
                    <p>Téléchargez l'application mobile <strong>HistoClassAI</strong> sur votre téléphone pour commencer à analyser des lames histologiques.</p>
                </div>
            ";

            try 
            {
                await _emailService.SendEmailAsync(etudiant.Email, subject, body);
                emailSentCount++;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erreur d'envoi d'email pour {Email}", etudiant.Email);
            }
        }

        return Ok(new { message = $"{importedCount} étudiants importés ({emailSentCount} emails envoyés avec succès)." });
    }

    [HttpGet("{id}/scans")]
    public async Task<ActionResult<IEnumerable<EtudiantScanDto>>> GetScansEtudiant(Guid id)
    {
        var etudiantExiste = await _context.Utilisateurs.AnyAsync(u => u.Id == id && u.Role == RoleUtilisateur.Etudiant);
        if (!etudiantExiste)
        {
            return NotFound("Étudiant introuvable.");
        }

        var scans = await _context.Scans
            .Include(s => s.Tissu)
            .Where(s => s.UtilisateurId == id)
            .OrderByDescending(s => s.DateScan)
            .Select(s => new EtudiantScanDto
            {
                Id = s.Id,
                TissuId = s.TissuId,
                TissuNom = s.Tissu.Nom,
                UrlImage = s.UrlImage,
                ScoreConfiance = s.ScoreConfiance,
                DateScan = s.DateScan
            })
            .ToListAsync();

        return Ok(scans);
    }
}
