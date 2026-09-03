using ClosedXML.Excel;
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

    /// <summary>
    /// Normalise une composante (Nom ou Prénom) pour l'email institutionnel :
    /// retire les accents, concatène en supprimant tous les espaces et caractères spéciaux, en minuscules.
    /// Ex: "EL HADRI" -> "elhadri", "Mohamed Yassine" -> "mohamedyassine", "BEN ABDELLAH" -> "benabdellah"
    /// </summary>
    private static string NormalizeForEmailPart(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return "";
        var normalized = text.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();
        foreach (var c in normalized)
        {
            var uc = CharUnicodeInfo.GetUnicodeCategory(c);
            if (uc != UnicodeCategory.NonSpacingMark)
            {
                if (char.IsLetterOrDigit(c))
                {
                    sb.Append(c);
                }
            }
        }
        return sb.ToString().ToLowerInvariant();
    }

    /// <summary>
    /// Génère un email unique nom.prenom@etu.uae.ac.ma selon la convention universitaire :
    /// un seul point séparant le nom et le prénom, avec suffixe numérique si doublon.
    /// Ex: "elhadri.mohamedyassine@etu.uae.ac.ma", "benabdellah.mosab@etu.uae.ac.ma"
    /// </summary>
    private async Task<string> GenerateUniqueEmailAsync(string prenom, string nom)
    {
        var n = NormalizeForEmailPart(nom);
        var p = NormalizeForEmailPart(prenom);
        string localPart;
        if (!string.IsNullOrEmpty(n) && !string.IsNullOrEmpty(p))
            localPart = $"{n}.{p}";
        else if (!string.IsNullOrEmpty(n))
            localPart = n;
        else
            localPart = p;

        localPart = localPart.Trim('.');

        var emailBase = $"{localPart}@etu.uae.ac.ma";
        var email = emailBase;
        int index = 1;
        while (await _context.Utilisateurs.AnyAsync(u => u.Email == email))
        {
            email = $"{localPart}{index}@etu.uae.ac.ma";
            index++;
        }
        return email;
    }

    /// <summary>
    /// Génère un mot de passe aléatoire de 8 caractères.
    /// </summary>
    private static string GenerateRandomPassword()
    {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        var random = new Random();
        return new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());
    }

    /// <summary>
    /// Construit le corps HTML de l'email de bienvenue.
    /// </summary>
    private static string BuildWelcomeEmailBody(string prenom, string email, string password)
    {
        return $@"
            <div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;"">
                <h2 style=""color: #4F46E5;"">Bienvenue sur HistoClassAI, {prenom} !</h2>
                <p>Votre compte étudiant a été créé par votre professeur.</p>
                <p>Voici vos identifiants pour vous connecter sur l'application mobile :</p>
                <div style=""background: #f8fafc; padding: 16px; border-radius: 6px; border-left: 4px solid #4F46E5; margin: 16px 0;"">
                    <p style=""margin: 4px 0;""><strong>Email :</strong> <span style=""color: #1e293b;"">{email}</span></p>
                    <p style=""margin: 4px 0;""><strong>Mot de passe :</strong> <span style=""color: #4F46E5; font-family: monospace; font-size: 16px; font-weight: bold;"">{password}</span></p>
                </div>
                <p>Téléchargez l'application mobile <strong>HistoClassAI</strong> sur votre téléphone pour commencer à analyser des lames histologiques.</p>
                <hr style=""border: none; border-top: 1px solid #eeeeee; margin: 20px 0;"" />
                <p style=""font-size: 12px; color: #64748b;"">Cet email a été envoyé automatiquement par la plateforme HistoClassAI.</p>
            </div>
        ";
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
                GroupeTp = u.GroupeTp,
                Apogee = u.Apogee,
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
        etudiant.GroupeTp = dto.GroupeTp?.Trim();
        etudiant.Apogee = dto.Apogee?.Trim();

        await _context.SaveChangesAsync();

        return Ok(new EtudiantResponseDto
        {
            Id = etudiant.Id,
            Nom = etudiant.Nom,
            Prenom = etudiant.Prenom,
            Email = etudiant.Email,
            EstActif = etudiant.EstActif,
            GroupeTp = etudiant.GroupeTp,
            Apogee = etudiant.Apogee,
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
            newPassword = GenerateRandomPassword();
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
            email = await GenerateUniqueEmailAsync(dto.Prenom, dto.Nom);
        }

        var password = GenerateRandomPassword();

        var etudiant = new Models.Utilisateur
        {
            Id = Guid.NewGuid(),
            Nom = dto.Nom.Trim(),
            Prenom = dto.Prenom.Trim(),
            Email = email,
            MotDePasseHash = BCrypt.Net.BCrypt.HashPassword(password),
            Role = RoleUtilisateur.Etudiant,
            GroupeTp = dto.GroupeTp?.Trim(),
            Apogee = dto.Apogee?.Trim(),
            DateCreation = DateTime.UtcNow
        };

        _context.Utilisateurs.Add(etudiant);
        await _context.SaveChangesAsync();

        // Envoi de l'email réel
        var subject = "Vos identifiants HistoClassAI";
        var body = BuildWelcomeEmailBody(etudiant.Prenom, etudiant.Email, password);

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
            GroupeTp = etudiant.GroupeTp,
            Apogee = etudiant.Apogee,
            DateCreation = etudiant.DateCreation
        };

        return CreatedAtAction(nameof(GetEtudiants), new { id = etudiant.Id }, responseDto);
    }

    /// <summary>
    /// Importe une liste d'étudiants depuis un fichier Excel (.xlsx) ou CSV (.csv).
    /// Structure Excel attendue (fichier officiel Faculté de Médecine) :
    /// Colonne 1 = Groupe, Colonne 2 = Apogée, Colonne 3 = Nom, Colonne 4 = Prénom.
    /// Gère les cellules fusionnées sur la colonne Groupe.
    /// </summary>
    [HttpPost("import")]
    public async Task<IActionResult> ImportEtudiants(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("Le fichier est invalide ou vide.");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (extension != ".xlsx" && extension != ".csv")
        {
            return BadRequest("Format de fichier non supporté. Utilisez un fichier .xlsx ou .csv.");
        }

        var result = new ImportResultDto();

        try
        {
            List<(string Groupe, string Apogee, string Nom, string Prenom)> rows;

            if (extension == ".xlsx")
            {
                rows = ReadExcelFile(file, result);
            }
            else
            {
                rows = ReadCsvFile(file, result);
            }

            // Traiter chaque ligne
            foreach (var (groupe, apogee, nom, prenom) in rows)
            {
                result.TotalLignesTraitees++;

                try
                {
                    if (string.IsNullOrWhiteSpace(nom) || string.IsNullOrWhiteSpace(prenom))
                    {
                        result.Erreurs++;
                        result.Details.Add($"Ligne ignorée : Nom ou Prénom manquant (Nom=\"{nom}\", Prénom=\"{prenom}\").");
                        continue;
                    }

                    var email = await GenerateUniqueEmailAsync(prenom, nom);

                    // Vérifier si un étudiant avec le même Apogée existe déjà
                    if (!string.IsNullOrWhiteSpace(apogee) &&
                        await _context.Utilisateurs.AnyAsync(u => u.Apogee == apogee))
                    {
                        result.Doublons++;
                        result.Details.Add($"Doublon ignoré : {prenom} {nom} (Apogée {apogee} déjà existant).");
                        continue;
                    }

                    var password = GenerateRandomPassword();

                    var etudiant = new Models.Utilisateur
                    {
                        Id = Guid.NewGuid(),
                        Nom = nom.Trim(),
                        Prenom = prenom.Trim(),
                        Email = email,
                        MotDePasseHash = BCrypt.Net.BCrypt.HashPassword(password),
                        Role = RoleUtilisateur.Etudiant,
                        GroupeTp = string.IsNullOrWhiteSpace(groupe) ? null : groupe.Trim(),
                        Apogee = string.IsNullOrWhiteSpace(apogee) ? null : apogee.Trim(),
                        DateCreation = DateTime.UtcNow
                    };

                    _context.Utilisateurs.Add(etudiant);
                    await _context.SaveChangesAsync();
                    result.Ajoutes++;

                    // Envoi de l'email
                    try
                    {
                        var subject = "Vos identifiants HistoClassAI";
                        var body = BuildWelcomeEmailBody(etudiant.Prenom, etudiant.Email, password);
                        await _emailService.SendEmailAsync(etudiant.Email, subject, body);
                        result.EmailsEnvoyes++;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Email non envoyé à {Email} (le compte a été créé)", etudiant.Email);
                    }
                }
                catch (Exception ex)
                {
                    result.Erreurs++;
                    result.Details.Add($"Erreur pour {prenom} {nom} : {ex.Message}");
                    _logger.LogError(ex, "Erreur lors de l'import de l'étudiant {Prenom} {Nom}", prenom, nom);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erreur fatale lors de la lecture du fichier d'import");
            return BadRequest($"Erreur lors de la lecture du fichier : {ex.Message}");
        }

        return Ok(result);
    }

    /// <summary>
    /// Lit un fichier Excel (.xlsx) avec ClosedXML.
    /// Gère les cellules fusionnées sur la colonne Groupe en mémorisant la dernière valeur non vide.
    /// Structure : Col1=Groupe, Col2=Apogée, Col3=Nom, Col4=Prénom
    /// </summary>
    private List<(string Groupe, string Apogee, string Nom, string Prenom)> ReadExcelFile(IFormFile file, ImportResultDto result)
    {
        var rows = new List<(string, string, string, string)>();

        using var stream = file.OpenReadStream();
        using var workbook = new XLWorkbook(stream);
        var worksheet = workbook.Worksheets.First();

        var lastGroupeValue = string.Empty;
        var usedRows = worksheet.RowsUsed().ToList();

        // Ignorer la première ligne (en-tête)
        foreach (var row in usedRows.Skip(1))
        {
            try
            {
                var groupeCell = row.Cell(1).GetFormattedString().Trim();
                var apogee = row.Cell(2).GetFormattedString().Trim();
                var nom = row.Cell(3).GetFormattedString().Trim();
                var prenom = row.Cell(4).GetFormattedString().Trim();

                // Gestion des cellules fusionnées : mémoriser la dernière valeur de Groupe non vide
                if (!string.IsNullOrWhiteSpace(groupeCell))
                {
                    lastGroupeValue = groupeCell;
                }

                // Ignorer les lignes complètement vides (ni nom ni prénom)
                if (string.IsNullOrWhiteSpace(nom) && string.IsNullOrWhiteSpace(prenom))
                {
                    continue;
                }

                rows.Add((lastGroupeValue, apogee, nom, prenom));
            }
            catch (Exception ex)
            {
                result.Erreurs++;
                result.Details.Add($"Erreur de lecture à la ligne {row.RowNumber()} : {ex.Message}");
                _logger.LogWarning(ex, "Erreur de lecture Excel à la ligne {Row}", row.RowNumber());
            }
        }

        return rows;
    }

    /// <summary>
    /// Lit un fichier CSV. Format attendu : Groupe;Apogée;Nom;Prenom (ou avec virgule).
    /// </summary>
    private List<(string Groupe, string Apogee, string Nom, string Prenom)> ReadCsvFile(IFormFile file, ImportResultDto result)
    {
        var rows = new List<(string, string, string, string)>();

        using var reader = new StreamReader(file.OpenReadStream());
        var isFirstLine = true;
        var lastGroupeValue = string.Empty;
        var lineNumber = 0;

        while (!reader.EndOfStream)
        {
            lineNumber++;
            var line = reader.ReadLine();
            if (string.IsNullOrWhiteSpace(line)) continue;

            // Ignorer la première ligne (en-tête)
            if (isFirstLine)
            {
                isFirstLine = false;
                continue;
            }

            try
            {
                var parts = line.Split(new[] { ',', ';', '\t' }, StringSplitOptions.None);

                if (parts.Length >= 4)
                {
                    // Format à 4 colonnes : Groupe, Apogée, Nom, Prénom
                    var groupe = parts[0].Trim();
                    var apogee = parts[1].Trim();
                    var nom = parts[2].Trim();
                    var prenom = parts[3].Trim();

                    if (!string.IsNullOrWhiteSpace(groupe))
                        lastGroupeValue = groupe;

                    if (!string.IsNullOrWhiteSpace(nom) || !string.IsNullOrWhiteSpace(prenom))
                        rows.Add((lastGroupeValue, apogee, nom, prenom));
                }
                else if (parts.Length >= 2)
                {
                    // Format simplifié : Nom, Prénom (rétro-compatible)
                    var nom = parts[0].Trim();
                    var prenom = parts[1].Trim();

                    if (!string.IsNullOrWhiteSpace(nom) || !string.IsNullOrWhiteSpace(prenom))
                        rows.Add((string.Empty, string.Empty, nom, prenom));
                }
                else
                {
                    result.Erreurs++;
                    result.Details.Add($"Ligne CSV {lineNumber} ignorée : format invalide ({parts.Length} colonne(s)).");
                }
            }
            catch (Exception ex)
            {
                result.Erreurs++;
                result.Details.Add($"Erreur de lecture CSV à la ligne {lineNumber} : {ex.Message}");
            }
        }

        return rows;
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
