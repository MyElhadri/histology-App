using System;
using System.Collections.Generic;

namespace HistoClassAI.Api.DTOs;

public class CreateOrganeDto
{
    public string Nom { get; set; } = string.Empty;
}

public class CreateQuestionDto
{
    public Guid TissuId { get; set; }
    public string Texte { get; set; } = string.Empty;
    public List<CreateChoixDto> Choix { get; set; } = new();
}

public class CreateChoixDto
{
    public string Texte { get; set; } = string.Empty;
    public bool EstCorrect { get; set; }
}

public class QuestionResponseDto
{
    public Guid Id { get; set; }
    public Guid TissuId { get; set; }
    public string Texte { get; set; } = string.Empty;
    public List<ChoixResponseDto> Choix { get; set; } = new();
}

public class ChoixResponseDto
{
    public Guid Id { get; set; }
    public string Texte { get; set; } = string.Empty;
    public bool EstCorrect { get; set; }
}

public class EtudiantResponseDto
{
    public Guid Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool EstActif { get; set; } = true;
    public string? MotDePasseGenere { get; set; }
    public bool EmailEnvoye { get; set; }
    public DateTime DateCreation { get; set; }
}

public class AddEtudiantDto
{
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public string? Email { get; set; }
}

public class UpdateEtudiantDto
{
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool EstActif { get; set; } = true;
}

public class ResetPasswordDto
{
    public string? NouveauMotDePasse { get; set; }
    public bool EnvoyerEmail { get; set; } = true;
}

public class EtudiantScanDto
{
    public Guid Id { get; set; }
    public Guid TissuId { get; set; }
    public string TissuNom { get; set; } = string.Empty;
    public string UrlImage { get; set; } = string.Empty;
    public float ScoreConfiance { get; set; }
    public DateTime DateScan { get; set; }
    public int? NoteQcm { get; set; }
    public int? TotalQuestionsQcm { get; set; }
    public DateTime? DateQcm { get; set; }
}
