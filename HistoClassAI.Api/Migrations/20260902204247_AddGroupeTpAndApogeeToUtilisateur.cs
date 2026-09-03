using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HistoClassAI.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddGroupeTpAndApogeeToUtilisateur : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Apogee",
                table: "Utilisateurs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GroupeTp",
                table: "Utilisateurs",
                type: "text",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Utilisateurs",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Apogee", "GroupeTp" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Apogee",
                table: "Utilisateurs");

            migrationBuilder.DropColumn(
                name: "GroupeTp",
                table: "Utilisateurs");
        }
    }
}
