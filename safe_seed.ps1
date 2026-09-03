$ErrorActionPreference = "Stop"
Write-Host "Truncating Tissus cascade..."
docker exec histoclass-postgres psql -U postgres -d histoclass_db -c "BEGIN; TRUNCATE TABLE `"Tissus`" CASCADE; COMMIT;"

if ($LASTEXITCODE -ne 0) {
    Write-Host "TRUNCATE failed."
    exit 1
}

Write-Host "Running seed_data.ps1..."
try {
    .\seed_data.ps1
} catch {
    Write-Host "Seed failed! Restoring backup..."
    docker exec -i histoclass-postgres psql -U postgres -d histoclass_db < .\backup_histoclass_db.sql
    Write-Host "Backup restored."
    exit 1
}
Write-Host "Safe seed completed successfully."
