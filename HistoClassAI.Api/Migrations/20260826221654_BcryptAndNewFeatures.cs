using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HistoClassAI.Api.Migrations
{
    /// <inheritdoc />
    public partial class BcryptAndNewFeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Utilisateurs",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "MotDePasseHash",
                value: "$2b$11$fTfL/3IcR68yUcqCVNivY.8nKLeWOCllsI883yEfIhdac84w5XFHO");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Utilisateurs",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "MotDePasseHash",
                value: "admin123");
        }
    }
}
