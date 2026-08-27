using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HistoClassAI.Api.Data;
using HistoClassAI.Api.Models.Enums;

namespace HistoClassAI.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StatsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public StatsController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetStats()
    {
        var totalStudents = await _context.Utilisateurs.CountAsync(u => u.Role == RoleUtilisateur.Etudiant);
        var totalTissus = await _context.Tissus.CountAsync();
        var totalOrganes = await _context.Organes.CountAsync();
        var totalQuestions = await _context.Questions.CountAsync();
        var totalScans = await _context.Scans.CountAsync();

        return Ok(new
        {
            TotalStudents = totalStudents,
            TotalTissus = totalTissus,
            TotalOrganes = totalOrganes,
            TotalQuestions = totalQuestions,
            TotalScans = totalScans
        });
    }
}
