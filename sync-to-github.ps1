# =============================================================
# SYNC PORTFOLIO → GITHUB
# =============================================================
# Copie les 14 fiches HTML portables vers le clone GitHub
# et push automatiquement sur main.
#
# UTILISATION :
#   1. Ouvre PowerShell DANS le dossier "Portfolio BAZAR ORGANISE"
#      (clic droit dans le dossier → "Ouvrir dans le Terminal")
#   2. Lance :  .\sync-to-github.ps1
#
# Si Windows refuse l'exécution, lance AVANT (une seule fois) :
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
# =============================================================

$ErrorActionPreference = "Stop"

# --- CONFIG ---
$GitHubDir   = "C:\Users\Elodie\Documents\CLAUDE\GitHub\bazar-organise"
$PortfolioDir = $PSScriptRoot
$CommitMsg   = "Refonte portfolio : format Skate + portabilite (images en base64)"

Write-Host ""
Write-Host "===== SYNC PORTFOLIO -> GITHUB =====" -ForegroundColor Cyan
Write-Host ""

# --- VERIFICATIONS ---
if (-not (Test-Path $GitHubDir)) {
    Write-Host "ERREUR : dossier GitHub introuvable -> $GitHubDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$GitHubDir\.git")) {
    Write-Host "ERREUR : pas un depot git -> $GitHubDir" -ForegroundColor Red
    exit 1
}

$SrcProjets = Join-Path $PortfolioDir "projets"
if (-not (Test-Path $SrcProjets)) {
    Write-Host "ERREUR : dossier 'projets' introuvable dans $PortfolioDir" -ForegroundColor Red
    Write-Host "Place ce script a la racine du dossier Portfolio." -ForegroundColor Yellow
    exit 1
}

# --- COPIE DES FICHIERS ---
$DestProjets = Join-Path $GitHubDir "projets"
if (-not (Test-Path $DestProjets)) {
    New-Item -ItemType Directory -Path $DestProjets | Out-Null
}

Write-Host "[1/3] Copie des 14 fiches HTML portables..." -ForegroundColor Green
$Files = Get-ChildItem "$SrcProjets\*.html"
foreach ($f in $Files) {
    Copy-Item $f.FullName -Destination $DestProjets -Force
    $sizeMB = [math]::Round($f.Length / 1MB, 1)
    Write-Host "   -> $($f.Name)  ($sizeMB MB)"
}

# --- GIT ---
Set-Location $GitHubDir

Write-Host ""
Write-Host "[2/3] git add + commit..." -ForegroundColor Green
git add projets/
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "   Rien a commiter (fichiers deja a jour)." -ForegroundColor Yellow
} else {
    git commit -m $CommitMsg
}

Write-Host ""
Write-Host "[3/3] git push origin main..." -ForegroundColor Green
git push origin main

Write-Host ""
Write-Host "===== TERMINE =====" -ForegroundColor Cyan
Write-Host "Verifie : https://github.com/spreadzloverz/bazar-organise" -ForegroundColor White
Write-Host ""
