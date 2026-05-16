param([string]$ProfileSrc)

function ok($m)   { Write-Host "[OK] $m" -ForegroundColor Green }
function inf($m)  { Write-Host "[ >] $m" -ForegroundColor Cyan }
function warn($m) { Write-Host "[!]  $m" -ForegroundColor Yellow }
function err($m)  { Write-Host "[X]  $m" -ForegroundColor Red }

Write-Host ""
Write-Host "=== Andro Windows Setup ===" -ForegroundColor Cyan
Write-Host ""

# PowerShell 7
inf "Pruefe PowerShell 7..."
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    ok "PowerShell 7 bereits installiert."
} else {
    inf "Installiere PowerShell 7..."
    winget install --id Microsoft.PowerShell --source winget --silent --accept-source-agreements --accept-package-agreements
    ok "PowerShell 7 installiert."
}

# Windows Terminal
inf "Pruefe Windows Terminal..."
$wtCheck = winget list --id Microsoft.WindowsTerminal --exact 2>&1
if ($wtCheck -match "Microsoft.WindowsTerminal") {
    ok "Windows Terminal bereits installiert."
} else {
    inf "Installiere Windows Terminal..."
    winget install --id Microsoft.WindowsTerminal --source winget --silent --accept-source-agreements --accept-package-agreements
    ok "Windows Terminal installiert."
}

# Profil kopieren
inf "Kopiere Profil..."
$profileDir = Join-Path $env:USERPROFILE "Documents\PowerShell"
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
$dst = Join-Path $profileDir "Microsoft.PowerShell_profile.ps1"
Copy-Item -Path $ProfileSrc -Destination $dst -Force
ok "Profil kopiert nach: $dst"

# Windows Terminal settings.json
inf "Suche Windows Terminal settings.json..."
$candidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    "$env:APPDATA\Microsoft\Windows Terminal\settings.json"
)
$wtSettings = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($wtSettings) {
    ok "Gefunden: $wtSettings"
    try {
        $json = Get-Content $wtSettings -Raw -Encoding UTF8 | ConvertFrom-Json
        $ps7  = $json.profiles.list | Where-Object {
            $_.name -match "PowerShell" -and $_.name -notmatch "5|Windows"
        } | Select-Object -First 1

        if ($ps7) {
            $json | Add-Member -MemberType NoteProperty -Name "defaultProfile" -Value $ps7.guid -Force
            $json | ConvertTo-Json -Depth 20 | Set-Content $wtSettings -Encoding UTF8
            ok "PowerShell 7 als Standardprofil gesetzt: $($ps7.name)"
        } else {
            warn "PS7-Profil nicht in settings.json - bitte manuell setzen."
        }
    } catch {
        warn "settings.json Fehler: $_"
    }
} else {
    warn "Windows Terminal noch nicht gestartet - settings.json fehlt."
    warn "Bitte einmal Windows Terminal oeffnen, schliessen, dann setup.ps1 nochmal ausfuehren."
}

# Registry: Windows Terminal als Standard-Terminalanwendung
inf "Setze Windows Terminal als Standard-Terminal..."
try {
    $rp = "HKCU:\Console\%Startup"
    if (-not (Test-Path $rp)) { New-Item -Path $rp -Force | Out-Null }
    Set-ItemProperty -Path $rp -Name "DelegationConsole"  -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
    Set-ItemProperty -Path $rp -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
    ok "Windows Terminal als Standard-Terminal gesetzt."
} catch {
    warn "Registry-Fehler: $_"
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  Setup abgeschlossen!" -ForegroundColor Green
Write-Host "  1. Windows Terminal neu starten" -ForegroundColor Green
Write-Host "  2. PowerShell 7 startet automatisch" -ForegroundColor Green
Write-Host "  3. Bootstrap laeuft beim 1. Start" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
