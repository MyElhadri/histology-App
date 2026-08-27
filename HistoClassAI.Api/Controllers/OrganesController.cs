using HistoClassAI.Api.Data;
using HistoClassAI.Api.DTOs;
using HistoClassAI.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HistoClassAI.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = "Professeur")]
public class OrganesController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public OrganesController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrganeDto>>> GetOrganes()
    {
        var organes = await _context.Organes
            .Select(o => new OrganeDto
            {
                Id = o.Id,
                Nom = o.Nom
            })
            .ToListAsync();

        return Ok(organes);
    }

    [HttpPost]
    public async Task<ActionResult<OrganeDto>> CreateOrgane(CreateOrganeDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Nom))
        {
            return BadRequest("Le nom de l'organe est obligatoire.");
        }

        var organe = new Organe
        {
            Id = Guid.NewGuid(),
            Nom = dto.Nom
        };

        _context.Organes.Add(organe);
        await _context.SaveChangesAsync();

        var responseDto = new OrganeDto
        {
            Id = organe.Id,
            Nom = organe.Nom
        };

        return CreatedAtAction(nameof(GetOrganes), new { id = organe.Id }, responseDto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateOrgane(Guid id, CreateOrganeDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Nom))
        {
            return BadRequest("Le nom de l'organe est obligatoire.");
        }

        var organe = await _context.Organes.FindAsync(id);
        if (organe == null)
        {
            return NotFound();
        }

        organe.Nom = dto.Nom;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteOrgane(Guid id)
    {
        var organe = await _context.Organes.FindAsync(id);
        if (organe == null)
        {
            return NotFound();
        }

        _context.Organes.Remove(organe);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
