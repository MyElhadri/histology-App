using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HistoClassAI.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Organes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nom = table.Column<string>(type: "text", nullable: false),
                    UrlImage = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Organes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Tissus",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nom = table.Column<string>(type: "text", nullable: false),
                    CodeLabelIa = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Fonctions = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tissus", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Utilisateurs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nom = table.Column<string>(type: "text", nullable: false),
                    Prenom = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    MotDePasseHash = table.Column<string>(type: "text", nullable: false),
                    Role = table.Column<string>(type: "text", nullable: false),
                    DateCreation = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Utilisateurs", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Questions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TissuId = table.Column<Guid>(type: "uuid", nullable: false),
                    Texte = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Questions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Questions_Tissus_TissuId",
                        column: x => x.TissuId,
                        principalTable: "Tissus",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TissuOrganes",
                columns: table => new
                {
                    TissuId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganeId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TissuOrganes", x => new { x.TissuId, x.OrganeId });
                    table.ForeignKey(
                        name: "FK_TissuOrganes_Organes_OrganeId",
                        column: x => x.OrganeId,
                        principalTable: "Organes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TissuOrganes_Tissus_TissuId",
                        column: x => x.TissuId,
                        principalTable: "Tissus",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Scans",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UtilisateurId = table.Column<Guid>(type: "uuid", nullable: false),
                    TissuId = table.Column<Guid>(type: "uuid", nullable: false),
                    UrlImage = table.Column<string>(type: "text", nullable: false),
                    ScoreConfiance = table.Column<float>(type: "real", nullable: false),
                    DateScan = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Scans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Scans_Tissus_TissuId",
                        column: x => x.TissuId,
                        principalTable: "Tissus",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Scans_Utilisateurs_UtilisateurId",
                        column: x => x.UtilisateurId,
                        principalTable: "Utilisateurs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Choix",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    QuestionId = table.Column<Guid>(type: "uuid", nullable: false),
                    Texte = table.Column<string>(type: "text", nullable: false),
                    EstCorrect = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Choix", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Choix_Questions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "Questions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ResultatsQCM",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UtilisateurId = table.Column<Guid>(type: "uuid", nullable: false),
                    ScanId = table.Column<Guid>(type: "uuid", nullable: false),
                    Note = table.Column<int>(type: "integer", nullable: false),
                    DateTest = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ResultatsQCM", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ResultatsQCM_Scans_ScanId",
                        column: x => x.ScanId,
                        principalTable: "Scans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ResultatsQCM_Utilisateurs_UtilisateurId",
                        column: x => x.UtilisateurId,
                        principalTable: "Utilisateurs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Choix_QuestionId",
                table: "Choix",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_TissuId",
                table: "Questions",
                column: "TissuId");

            migrationBuilder.CreateIndex(
                name: "IX_ResultatsQCM_ScanId",
                table: "ResultatsQCM",
                column: "ScanId");

            migrationBuilder.CreateIndex(
                name: "IX_ResultatsQCM_UtilisateurId",
                table: "ResultatsQCM",
                column: "UtilisateurId");

            migrationBuilder.CreateIndex(
                name: "IX_Scans_TissuId",
                table: "Scans",
                column: "TissuId");

            migrationBuilder.CreateIndex(
                name: "IX_Scans_UtilisateurId",
                table: "Scans",
                column: "UtilisateurId");

            migrationBuilder.CreateIndex(
                name: "IX_TissuOrganes_OrganeId",
                table: "TissuOrganes",
                column: "OrganeId");

            migrationBuilder.CreateIndex(
                name: "IX_Tissus_CodeLabelIa",
                table: "Tissus",
                column: "CodeLabelIa",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Utilisateurs_Email",
                table: "Utilisateurs",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Choix");

            migrationBuilder.DropTable(
                name: "ResultatsQCM");

            migrationBuilder.DropTable(
                name: "TissuOrganes");

            migrationBuilder.DropTable(
                name: "Questions");

            migrationBuilder.DropTable(
                name: "Scans");

            migrationBuilder.DropTable(
                name: "Organes");

            migrationBuilder.DropTable(
                name: "Tissus");

            migrationBuilder.DropTable(
                name: "Utilisateurs");
        }
    }
}
