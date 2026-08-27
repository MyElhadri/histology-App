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
public class QuestionsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public QuestionsController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet("tissu/{tissuId}")]
    public async Task<ActionResult<IEnumerable<QuestionResponseDto>>> GetQuestionsByTissu(Guid tissuId)
    {
        var questions = await _context.Questions
            .Include(q => q.Choix)
            .Where(q => q.TissuId == tissuId)
            .Select(q => new QuestionResponseDto
            {
                Id = q.Id,
                TissuId = q.TissuId,
                Texte = q.Texte,
                Choix = q.Choix.Select(c => new ChoixResponseDto
                {
                    Id = c.Id,
                    Texte = c.Texte,
                    EstCorrect = c.EstCorrect
                }).ToList()
            })
            .ToListAsync();

        return Ok(questions);
    }

    [HttpPost]
    public async Task<ActionResult<QuestionResponseDto>> CreateQuestion(CreateQuestionDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Texte) || dto.Choix == null || dto.Choix.Count < 2)
        {
            return BadRequest("Une question doit avoir un texte et au moins 2 choix.");
        }

        if (!dto.Choix.Any(c => c.EstCorrect))
        {
            return BadRequest("Il faut au moins une réponse correcte.");
        }

        var tissuExiste = await _context.Tissus.AnyAsync(t => t.Id == dto.TissuId);
        if (!tissuExiste)
        {
            return NotFound("Le tissu spécifié n'existe pas.");
        }

        var question = new Question
        {
            Id = Guid.NewGuid(),
            TissuId = dto.TissuId,
            Texte = dto.Texte,
            Choix = dto.Choix.Select(c => new Choix
            {
                Id = Guid.NewGuid(),
                Texte = c.Texte,
                EstCorrect = c.EstCorrect
            }).ToList()
        };

        _context.Questions.Add(question);
        await _context.SaveChangesAsync();

        var responseDto = new QuestionResponseDto
        {
            Id = question.Id,
            TissuId = question.TissuId,
            Texte = question.Texte,
            Choix = question.Choix.Select(c => new ChoixResponseDto
            {
                Id = c.Id,
                Texte = c.Texte,
                EstCorrect = c.EstCorrect
            }).ToList()
        };

        return CreatedAtAction(nameof(GetQuestionsByTissu), new { tissuId = question.TissuId }, responseDto);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteQuestion(Guid id)
    {
        var question = await _context.Questions.FindAsync(id);
        if (question == null)
        {
            return NotFound();
        }

        _context.Questions.Remove(question);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
