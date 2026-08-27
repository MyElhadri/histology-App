using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HistoClassAI.Api.Migrations
{
    /// <inheritdoc />
    public partial class SeedTissus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Organes",
                columns: new[] { "Id", "Nom", "UrlImage" },
                values: new object[] { new Guid("33333333-3333-3333-3333-333333333333"), "Épiderme", "" });

            migrationBuilder.InsertData(
                table: "Tissus",
                columns: new[] { "Id", "CodeLabelIa", "Description", "Fonctions", "Nom" },
                values: new object[] { new Guid("22222222-2222-2222-2222-222222222222"), "classe_04", "Tissu formé de plusieurs couches de cellules.", "Protection contre l'abrasion.", "Épithélium Stratifié" });

            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "Texte", "TissuId" },
                values: new object[] { new Guid("44444444-4444-4444-4444-444444444444"), "Quelle est la principale fonction de l'épithélium stratifié ?", new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.InsertData(
                table: "TissuOrganes",
                columns: new[] { "OrganeId", "TissuId" },
                values: new object[] { new Guid("33333333-3333-3333-3333-333333333333"), new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.InsertData(
                table: "Choix",
                columns: new[] { "Id", "EstCorrect", "QuestionId", "Texte" },
                values: new object[,]
                {
                    { new Guid("55555555-5555-5555-5555-555555555555"), true, new Guid("44444444-4444-4444-4444-444444444444"), "Protection contre l'abrasion" },
                    { new Guid("66666666-6666-6666-6666-666666666666"), false, new Guid("44444444-4444-4444-4444-444444444444"), "Absorption des nutriments" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Choix",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"));

            migrationBuilder.DeleteData(
                table: "Choix",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"));

            migrationBuilder.DeleteData(
                table: "TissuOrganes",
                keyColumns: new[] { "OrganeId", "TissuId" },
                keyValues: new object[] { new Guid("33333333-3333-3333-3333-333333333333"), new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.DeleteData(
                table: "Organes",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"));

            migrationBuilder.DeleteData(
                table: "Tissus",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"));
        }
    }
}
