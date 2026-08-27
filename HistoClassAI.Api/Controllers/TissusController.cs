using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs;
using HistoClassAI.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HistoClassAI.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = "Professeur")] // Sécurité stricte CMS
public class TissusController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TissusController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TissuResponseDto>>> GetTissus()
    {
        var tissus = await _context.Tissus
            .Include(t => t.TissuOrganes)
                .ThenInclude(to => to.Organe)
            .Include(t => t.Questions)
            .Select(t => new TissuResponseDto
            {
                Id = t.Id,
                Nom = t.Nom,
                Description = t.Description,
                Fonctions = t.Fonctions,
                CodeLabelIa = t.CodeLabelIa,
                Organes = t.TissuOrganes.Select(to => new OrganeDto
                {
                    Id = to.OrganeId,
                    Nom = to.Organe.Nom
                }).ToList(),
                NombreQuestions = t.Questions.Count
            })
            .ToListAsync();

        return Ok(tissus);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TissuResponseDto>> GetTissu(Guid id)
    {
        var tissu = await _context.Tissus
            .Include(t => t.TissuOrganes)
                .ThenInclude(to => to.Organe)
            .Include(t => t.Questions)
            .Where(t => t.Id == id)
            .Select(t => new TissuResponseDto
            {
                Id = t.Id,
                Nom = t.Nom,
                Description = t.Description,
                Fonctions = t.Fonctions,
                CodeLabelIa = t.CodeLabelIa,
                Organes = t.TissuOrganes.Select(to => new OrganeDto
                {
                    Id = to.OrganeId,
                    Nom = to.Organe.Nom
                }).ToList(),
                NombreQuestions = t.Questions.Count
            })
            .FirstOrDefaultAsync();

        if (tissu == null)
        {
            return NotFound();
        }

        return Ok(tissu);
    }

    [HttpPost]
    public async Task<ActionResult<TissuResponseDto>> CreateTissu(CreateTissuDto dto)
    {
        // Validation simple
        if (string.IsNullOrWhiteSpace(dto.Nom) || string.IsNullOrWhiteSpace(dto.CodeLabelIa))
        {
            return BadRequest("Le nom et le code de l'IA sont obligatoires.");
        }

        // Vérifier l'unicité du code label
        if (await _context.Tissus.AnyAsync(t => t.CodeLabelIa == dto.CodeLabelIa))
        {
            return Conflict($"Un tissu avec le code label '{dto.CodeLabelIa}' existe déjà.");
        }

        var tissu = new Tissu
        {
            Id = Guid.NewGuid(),
            Nom = dto.Nom,
            Description = dto.Description,
            Fonctions = dto.Fonctions,
            CodeLabelIa = dto.CodeLabelIa
        };

        // Associer les organes si fournis
        if (dto.OrganeIds.Count > 0)
        {
            var organes = await _context.Organes
                .Where(o => dto.OrganeIds.Contains(o.Id))
                .ToListAsync();

            foreach (var organe in organes)
            {
                tissu.TissuOrganes.Add(new TissuOrgane
                {
                    TissuId = tissu.Id,
                    OrganeId = organe.Id
                });
            }
        }

        _context.Tissus.Add(tissu);
        await _context.SaveChangesAsync();

        var responseDto = new TissuResponseDto
        {
            Id = tissu.Id,
            Nom = tissu.Nom,
            Description = tissu.Description,
            Fonctions = tissu.Fonctions,
            CodeLabelIa = tissu.CodeLabelIa,
            Organes = tissu.TissuOrganes.Select(to => new OrganeDto
            {
                Id = to.OrganeId,
                Nom = to.Organe?.Nom ?? ""
            }).ToList(),
            NombreQuestions = 0
        };

        return CreatedAtAction(nameof(GetTissu), new { id = tissu.Id }, responseDto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTissu(Guid id, CreateTissuDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Nom) || string.IsNullOrWhiteSpace(dto.CodeLabelIa))
        {
            return BadRequest("Le nom et le code de l'IA sont obligatoires.");
        }

        var tissu = await _context.Tissus
            .Include(t => t.TissuOrganes)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (tissu == null)
        {
            return NotFound();
        }

        // Vérifier l'unicité du code label si changé
        if (tissu.CodeLabelIa != dto.CodeLabelIa && await _context.Tissus.AnyAsync(t => t.CodeLabelIa == dto.CodeLabelIa))
        {
            return Conflict($"Un tissu avec le code label '{dto.CodeLabelIa}' existe déjà.");
        }

        tissu.Nom = dto.Nom;
        tissu.Description = dto.Description;
        tissu.Fonctions = dto.Fonctions;
        tissu.CodeLabelIa = dto.CodeLabelIa;

        // Mettre à jour les associations Tissu-Organe
        // Supprimer les anciennes associations
        _context.TissuOrganes.RemoveRange(tissu.TissuOrganes);

        // Ajouter les nouvelles associations
        if (dto.OrganeIds.Count > 0)
        {
            foreach (var organeId in dto.OrganeIds)
            {
                _context.TissuOrganes.Add(new TissuOrgane
                {
                    TissuId = tissu.Id,
                    OrganeId = organeId
                });
            }
        }

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTissu(Guid id)
    {
        var tissu = await _context.Tissus.FindAsync(id);
        if (tissu == null)
        {
            return NotFound();
        }

        _context.Tissus.Remove(tissu);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
