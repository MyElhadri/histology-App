using System.Security.Claims;
using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs;
using HistoClassAI.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HistoClassAI.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ResultatsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ResultatsController(ApplicationDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Enregistre le résultat d'un QCM après soumission par l'étudiant.
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ResultatResponseDto>> SubmitResultat(SubmitResultatDto dto)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdString, out Guid utilisateurId))
        {
            return Unauthorized("Impossible de lire l'identifiant de l'utilisateur.");
        }

        // Vérifier que le scan existe et appartient à l'utilisateur
        var scan = await _context.Scans
            .Include(s => s.Tissu)
            .FirstOrDefaultAsync(s => s.Id == dto.ScanId && s.UtilisateurId == utilisateurId);

        if (scan == null)
        {
            return NotFound("Scan introuvable ou non autorisé.");
        }

        var resultat = new ResultatQCM
        {
            Id = Guid.NewGuid(),
            UtilisateurId = utilisateurId,
            ScanId = dto.ScanId,
            Note = dto.Note,
            DateTest = DateTime.UtcNow
        };

        _context.ResultatsQCM.Add(resultat);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetMyResultats), null, new ResultatResponseDto
        {
            Id = resultat.Id,
            ScanId = resultat.ScanId,
            TissuNom = scan.Tissu.Nom,
            Note = resultat.Note,
            DateTest = resultat.DateTest
        });
    }

    /// <summary>
    /// Récupère l'historique des résultats QCM de l'utilisateur connecté.
    /// </summary>
    [HttpGet("my")]
    public async Task<ActionResult<IEnumerable<ResultatResponseDto>>> GetMyResultats()
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdString, out Guid utilisateurId))
        {
            return Unauthorized("Impossible de lire l'identifiant de l'utilisateur.");
        }

        var resultats = await _context.ResultatsQCM
            .Include(r => r.Scan)
                .ThenInclude(s => s.Tissu)
            .Where(r => r.UtilisateurId == utilisateurId)
            .OrderByDescending(r => r.DateTest)
            .Select(r => new ResultatResponseDto
            {
                Id = r.Id,
                ScanId = r.ScanId,
                TissuNom = r.Scan.Tissu.Nom,
                Note = r.Note,
                DateTest = r.DateTest
            })
            .ToListAsync();

        return Ok(resultats);
    }
}
