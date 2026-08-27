using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HistoClassAI.Api.Migrations
{
    /// <inheritdoc />
    public partial class SeedUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Utilisateurs",
                columns: new[] { "Id", "DateCreation", "Email", "MotDePasseHash", "Nom", "Prenom", "Role" },
                values: new object[] { new Guid("11111111-1111-1111-1111-111111111111"), new DateTime(2026, 8, 24, 0, 0, 0, 0, DateTimeKind.Utc), "prof@ensat.ma", "admin123", "Professeur", "Admin", "Professeur" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Utilisateurs",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"));
        }
    }
}
