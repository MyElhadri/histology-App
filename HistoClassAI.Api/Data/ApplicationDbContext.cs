using Microsoft.EntityFrameworkCore;
using HistoClassAI.Api.Models;

namespace HistoClassAI.Api.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Utilisateur> Utilisateurs => Set<Utilisateur>();
    public DbSet<Tissu> Tissus => Set<Tissu>();
    public DbSet<Organe> Organes => Set<Organe>();
    public DbSet<TissuOrgane> TissuOrganes => Set<TissuOrgane>();
    public DbSet<Scan> Scans => Set<Scan>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<Choix> Choix => Set<Choix>();
    public DbSet<ResultatQCM> ResultatsQCM => Set<ResultatQCM>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ── TissuOrgane : clé primaire composite (Many-to-Many) ──────
        modelBuilder.Entity<TissuOrgane>()
            .HasKey(to => new { to.TissuId, to.OrganeId });

        modelBuilder.Entity<TissuOrgane>()
            .HasOne(to => to.Tissu)
            .WithMany(t => t.TissuOrganes)
            .HasForeignKey(to => to.TissuId);

        modelBuilder.Entity<TissuOrgane>()
            .HasOne(to => to.Organe)
            .WithMany(o => o.TissuOrganes)
            .HasForeignKey(to => to.OrganeId);

        // ── Index unique sur Email ───────────────────────────────────
        modelBuilder.Entity<Utilisateur>()
            .HasIndex(u => u.Email)
            .IsUnique();

        // ── Index unique sur CodeLabelIa ─────────────────────────────
        modelBuilder.Entity<Tissu>()
            .HasIndex(t => t.CodeLabelIa)
            .IsUnique();

        // ── Cascade : Question → Choix (suppression en cascade) ─────
        modelBuilder.Entity<Choix>()
            .HasOne(c => c.Question)
            .WithMany(q => q.Choix)
            .HasForeignKey(c => c.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);

        // ── Restrict : Tissu → Scan (empêcher suppression) ──────────
        modelBuilder.Entity<Scan>()
            .HasOne(s => s.Tissu)
            .WithMany(t => t.Scans)
            .HasForeignKey(s => s.TissuId)
            .OnDelete(DeleteBehavior.Restrict);

        // ── Stockage de l'enum Role en string ────────────────────────
        modelBuilder.Entity<Utilisateur>()
            .Property(u => u.Role)
            .HasConversion<string>();

        // ── Utilisateur de Test (Seeding) ────────────────────────────
        modelBuilder.Entity<Utilisateur>().HasData(new Utilisateur
        {
            Id = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            Nom = "Professeur",
            Prenom = "Admin",
            Email = "prof@ensat.ma",
            MotDePasseHash = "$2b$11$fTfL/3IcR68yUcqCVNivY.8nKLeWOCllsI883yEfIhdac84w5XFHO", // BCrypt hash of "admin123"
            Role = HistoClassAI.Api.Models.Enums.RoleUtilisateur.Professeur,
            DateCreation = new DateTime(2026, 8, 24, 0, 0, 0, DateTimeKind.Utc)
        });

        // ── Seeding Tissu, Organe, QCM ───────────────────────────────
        var tissuId = Guid.Parse("22222222-2222-2222-2222-222222222222");
        modelBuilder.Entity<Tissu>().HasData(new Tissu
        {
            Id = tissuId,
            Nom = "Épithélium Stratifié",
            CodeLabelIa = "classe_04",
            Description = "Tissu formé de plusieurs couches de cellules.",
            Fonctions = "Protection contre l'abrasion."
        });

        var organeId = Guid.Parse("33333333-3333-3333-3333-333333333333");
        modelBuilder.Entity<Organe>().HasData(new Organe
        {
            Id = organeId,
            Nom = "Épiderme",
            UrlImage = ""
        });

        modelBuilder.Entity<TissuOrgane>().HasData(new TissuOrgane
        {
            TissuId = tissuId,
            OrganeId = organeId
        });

        var questionId = Guid.Parse("44444444-4444-4444-4444-444444444444");
        modelBuilder.Entity<Question>().HasData(new Question
        {
            Id = questionId,
            TissuId = tissuId,
            Texte = "Quelle est la principale fonction de l'épithélium stratifié ?"
        });

        modelBuilder.Entity<Choix>().HasData(
            new Choix { Id = Guid.Parse("55555555-5555-5555-5555-555555555555"), QuestionId = questionId, Texte = "Protection contre l'abrasion", EstCorrect = true },
            new Choix { Id = Guid.Parse("66666666-6666-6666-6666-666666666666"), QuestionId = questionId, Texte = "Absorption des nutriments", EstCorrect = false }
        );
    }
}
