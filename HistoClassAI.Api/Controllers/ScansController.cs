using System.Security.Claims;
using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs;
using HistoClassAI.Api.Models;
using HistoClassAI.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HistoClassAI.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ScansController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IMinioService _minioService;
    private readonly IIaService _iaService;
    private readonly ILogger<ScansController> _logger;

    public ScansController(
        ApplicationDbContext context,
        IMinioService minioService,
        IIaService iaService,
        ILogger<ScansController> logger)
    {
        _context = context;
        _minioService = minioService;
        _iaService = iaService;
        _logger = logger;
    }

    [HttpPost("analyze")]
    public async Task<ActionResult<ScanResultDto>> AnalyzeImage(IFormFile image)
    {
        if (image == null || image.Length == 0)
        {
            return BadRequest("L'image est requise.");
        }

        // a. Uploade l'image via IMinioService
        string imageUrl;
        try
        {
            imageUrl = await _minioService.UploadImageAsync(image);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erreur lors de l'upload de l'image");
            return StatusCode(500, "Erreur lors de la sauvegarde de l'image.");
        }

        // b. Appelle IIaService avec l'image
        string codeLabelIa;
        float confiance;
        try
        {
            var prediction = await _iaService.PredictAsync(image);
            codeLabelIa = prediction.CodeLabelIa;
            confiance = prediction.Confiance;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erreur lors de l'appel au service IA");
            // HTTP 503 propre pour signaler que le service IA a échoué (ex: souci Keras)
            return StatusCode(503, "Le service d'analyse IA est actuellement indisponible ou a renvoyé une erreur.");
        }

        // c. Cherche le Tissu et ses Organes dans la BDD grâce au CodeLabelIa
        var tissu = await _context.Tissus
            .Include(t => t.TissuOrganes)
                .ThenInclude(to => to.Organe)
            .FirstOrDefaultAsync(t => t.CodeLabelIa == codeLabelIa);

        if (tissu == null)
        {
            // Le modèle IA a retourné une classe qui n'est pas (encore) dans notre BDD
            return NotFound($"Le tissu reconnu par l'IA ({codeLabelIa}) n'existe pas dans la base de données.");
        }

        // d. Récupère 3 Questions (et leurs Choix) associées au Tissu (aléatoirement)
        var questions = await _context.Questions
            .Include(q => q.Choix)
            .Where(q => q.TissuId == tissu.Id)
            .OrderBy(q => Guid.NewGuid()) // Tri aléatoire très basique (Ok pour des petits volumes)
            .Take(3)
            .ToListAsync();

        // Récupérer l'ID de l'utilisateur connecté depuis le JWT
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdString, out Guid utilisateurId))
        {
            return Unauthorized("Impossible de lire l'identifiant de l'utilisateur.");
        }

        // e. Crée une entrée dans l'historique Scan et sauvegarde
        var scan = new Scan
        {
            Id = Guid.NewGuid(),
            UtilisateurId = utilisateurId,
            TissuId = tissu.Id,
            DateScan = DateTime.UtcNow,
            UrlImage = imageUrl,
            ScoreConfiance = confiance
        };

        _context.Scans.Add(scan);
        await _context.SaveChangesAsync();

        // f. Retourne le DTO complet
        var result = new ScanResultDto
        {
            ScanId = scan.Id,
            ImageUrl = imageUrl,
            CodeLabelIa = codeLabelIa,
            Confiance = confiance,
            TissuId = tissu.Id,
            NomTissu = tissu.Nom,
            DescriptionTissu = tissu.Description,
            Organes = tissu.TissuOrganes.Select(to => new OrganeDto
            {
                Id = to.OrganeId,
                Nom = to.Organe.Nom
            }).ToList(),
            Questions = questions.Select(q => new QuestionDto
            {
                Id = q.Id,
                Texte = q.Texte,
                Choix = q.Choix.Select(c => new ChoixDto
                {
                    Id = c.Id,
                    Texte = c.Texte,
                    EstCorrect = c.EstCorrect
                }).ToList()
            }).ToList()
        };

        return Ok(result);
    }

    /// <summary>
    /// Récupère l'historique des scans de l'utilisateur connecté (pour le mobile).
    /// </summary>
    [HttpGet("my")]
    public async Task<ActionResult<IEnumerable<EtudiantScanDto>>> GetMyScans()
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdString, out Guid utilisateurId))
        {
            return Unauthorized("Impossible de lire l'identifiant de l'utilisateur.");
        }

        var scans = await _context.Scans
            .Include(s => s.Tissu)
            .Include(s => s.ResultatsQCM)
            .Where(s => s.UtilisateurId == utilisateurId)
            .OrderByDescending(s => s.DateScan)
            .Select(s => new EtudiantScanDto
            {
                Id = s.Id,
                TissuId = s.TissuId,
                TissuNom = s.Tissu.Nom,
                UrlImage = s.UrlImage,
                ScoreConfiance = s.ScoreConfiance,
                DateScan = s.DateScan,
                NoteQcm = s.ResultatsQCM.OrderByDescending(r => r.DateTest).Select(r => (int?)r.Note).FirstOrDefault(),
                DateQcm = s.ResultatsQCM.OrderByDescending(r => r.DateTest).Select(r => (DateTime?)r.DateTest).FirstOrDefault(),
                TotalQuestionsQcm = 3
            })
            .ToListAsync();

        return Ok(scans);
    }
}
