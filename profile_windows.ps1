# =============================================================================
#  profile_windows.ps1 — Windows VM Bootstrap & PowerShell-Konfiguration
#
#  Installation (einmalig, am Ende von $PROFILE einfügen):
#    $vmProfile = "$HOME\profile_windows.ps1"
#    if (Test-Path $vmProfile) { . $vmProfile }
#
#  Oder direkt als Profil verwenden:
#    Copy-Item profile_windows.ps1 $PROFILE
#
#  Setup zurücksetzen:
#    vm-setup-reset
# =============================================================================

#region SETUP-BOOTSTRAP
$script:SetupFlag = "$HOME\.config\vm-bootstrap\setup_done"
$script:SetupLog  = "$HOME\.config\vm-bootstrap\setup.log"

function _has { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }
function _log  { param($msg) Write-Host "[✔] $msg" -ForegroundColor Green }
function _info { param($msg) Write-Host "[→] $msg" -ForegroundColor Cyan }
function _warn { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function _err  { param($msg) Write-Host "[✘] $msg" -ForegroundColor Red }

function _winget_install {
    param($id, $name)
    $installed = winget list --id $id --exact 2>$null | Select-String $id -Quiet
    if ($installed) { _info "$name bereits installiert, überspringe."; return }
    _info "Installiere $name..."
    winget install --id $id --silent --accept-source-agreements --accept-package-agreements 2>&1 |
        Add-Content $script:SetupLog
    _log "$name installiert."
}

function _setup_starship_config {
    $cfg = "$HOME\.config\starship.toml"
    if (Test-Path $cfg) { _info "Starship Config existiert bereits, überspringe."; return }
    _info "Erstelle Starship Config..."
    New-Item -ItemType Directory -Force -Path "$HOME\.config" | Out-Null
    Set-Content $cfg -Encoding UTF8 -Value @'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](red)\
$os\
$username\
[](bg:peach fg:red)\
$directory\
[](bg:yellow fg:peach)\
$git_branch\
$git_status\
[](fg:yellow bg:green)\
$c\
$rust\
$golang\
$nodejs\
$bun\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:green bg:sapphire)\
$conda\
[](fg:sapphire bg:lavender)\
$time\
[ ](fg:lavender)\
$cmd_duration\
$line_break\
$character"""

palette = 'catppuccin_mocha'

[os]
disabled = false
style = "bg:red fg:crust"

[os.symbols]
Windows = ""
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
AOSC = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:red fg:crust"
style_root = "bg:red fg:crust"
format = '[ $user]($style)'

[directory]
style = "bg:peach fg:crust"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:yellow"
format = '[[ $symbol $branch ](fg:crust bg:yellow)]($style)'

[git_status]
style = "bg:yellow"
format = '[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)'

[nodejs]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[bun]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[c]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[rust]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[golang]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[php]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[java]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[kotlin]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[haskell]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[python]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)'

[docker_context]
symbol = ""
style = "bg:sapphire"
format = '[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)'

[conda]
symbol = "  "
style = "fg:crust bg:sapphire"
format = '[$symbol$environment ]($style)'
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:lavender"
format = '[[  $time ](fg:crust bg:lavender)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[❯](bold fg:green)'
error_symbol = '[❯](bold fg:red)'
vimcmd_symbol = '[❮](bold fg:green)'
vimcmd_replace_one_symbol = '[❮](bold fg:lavender)'
vimcmd_replace_symbol = '[❮](bold fg:lavender)'
vimcmd_visual_symbol = '[❮](bold fg:yellow)'

[cmd_duration]
show_milliseconds = true
format = " in $duration "
style = "bg:lavender"
disabled = false
show_notifications = true
min_time_to_notify = 45000

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
mauve = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"

[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"
text = "#c6d0f5"
subtext1 = "#b5bfe2"
subtext0 = "#a5adce"
overlay2 = "#949cbb"
overlay1 = "#838ba7"
overlay0 = "#737994"
surface2 = "#626880"
surface1 = "#51576d"
surface0 = "#414559"
base = "#303446"
mantle = "#292c3c"
crust = "#232634"

[palettes.catppuccin_latte]
rosewater = "#dc8a78"
flamingo = "#dd7878"
pink = "#ea76cb"
mauve = "#8839ef"
red = "#d20f39"
maroon = "#e64553"
peach = "#fe640b"
yellow = "#df8e1d"
green = "#40a02b"
teal = "#179299"
sky = "#04a5e5"
sapphire = "#209fb5"
blue = "#1e66f5"
lavender = "#7287fd"
text = "#4c4f69"
subtext1 = "#5c5f77"
subtext0 = "#6c6f85"
overlay2 = "#7c7f93"
overlay1 = "#8c8fa1"
overlay0 = "#9ca0b0"
surface2 = "#acb0be"
surface1 = "#bcc0cc"
surface0 = "#ccd0da"
base = "#eff1f5"
mantle = "#e6e9ef"
crust = "#dce0e8"

[palettes.catppuccin_macchiato]
rosewater = "#f4dbd6"
flamingo = "#f0c6c6"
pink = "#f5bde6"
mauve = "#c6a0f6"
red = "#ed8796"
maroon = "#ee99a0"
peach = "#f5a97f"
yellow = "#eed49f"
green = "#a6da95"
teal = "#8bd5ca"
sky = "#91d7e3"
sapphire = "#7dc4e4"
blue = "#8aadf4"
lavender = "#b7bdf8"
text = "#cad3f5"
subtext1 = "#b8c0e0"
subtext0 = "#a5adcb"
overlay2 = "#939ab7"
overlay1 = "#8087a2"
overlay0 = "#6e738d"
surface2 = "#5b6078"
surface1 = "#494d64"
surface0 = "#363a4f"
base = "#24273a"
mantle = "#1e2030"
crust = "#181926"
'@
    _log "Starship Config erstellt."
}

function _setup_fastfetch_config {
    $cfg = "$HOME\.config\fastfetch\config.jsonc"
    if (Test-Path $cfg) { _info "Fastfetch Config existiert bereits, überspringe."; return }
    _info "Erstelle Fastfetch Config..."
    New-Item -ItemType Directory -Force -Path "$HOME\.config\fastfetch" | Out-Null
    Set-Content $cfg -Encoding UTF8 -Value @'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "source": "Windows 11",
    "color": {
      "1": "blue",
      "2": "blue",
      "3": "blue",
      "4": "blue"
    }
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "wm",
    "wmtheme",
    "theme",
    "icons",
    "font",
    "cursor",
    "terminal",
    "terminalfont",
    "cpu",
    "gpu",
    "memory",
    "localip",
    "break"
  ]
}
'@
    _log "Fastfetch Config erstellt."
}

function _install_nerd_font {
    $fontName = "CaskaydiaCoveNerdFont-Regular.ttf"
    $fontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $regPath  = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

    # Bereits installiert?
    if (Test-Path "$fontsDir\$fontName") {
        _info "CaskaydiaCove Nerd Font bereits installiert, überspringe."
        return
    }

    _info "Lade CaskaydiaCove Nerd Font herunter..."
    $zipUrl  = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    $zipPath = "$env:TEMP\CascadiaCode.zip"
    $unzipTo = "$env:TEMP\CascadiaCode"

    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
        _log "Download abgeschlossen."
    } catch {
        _err "Download fehlgeschlagen: $_"; return
    }

    _info "Entpacke Archiv..."
    Expand-Archive -Path $zipPath -DestinationPath $unzipTo -Force

    # Nur reguläre TTF-Dateien (kein Italic/Bold/Mono/Propo), Windows-Font-Ordner
    $ttfFiles = Get-ChildItem -Path $unzipTo -Filter "CaskaydiaCoveNerdFont-*.ttf" -Recurse |
                Where-Object { $_.Name -notmatch 'Italic|Bold|Mono|Propo' }

    if (-not $ttfFiles) {
        _err "Keine passenden TTF-Dateien gefunden."; return
    }

    New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null

    foreach ($ttf in $ttfFiles) {
        $dest = "$fontsDir\$($ttf.Name)"
        Copy-Item -Path $ttf.FullName -Destination $dest -Force

        # Pro-User Registry-Eintrag (kein Admin nötig)
        $regName = $ttf.BaseName + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $regName -Value $dest -ErrorAction SilentlyContinue
        _log "Font registriert: $($ttf.Name)"
    }

    # Windows Terminal: Font automatisch setzen
    # Alle bekannten Installationspfade prüfen:
    #   1) Microsoft Store (stabil)        2) Store Preview
    #   3) Winget / Portable (keine MSIX)  4) Scoop
    $wtCandidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
        "$env:APPDATA\Microsoft\Windows Terminal\settings.json"
    )
    $wtSettings = $wtCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($wtSettings) {
        _info "Windows Terminal gefunden: $wtSettings"
        _info "Setze CaskaydiaCove als Standard-Font..."
        try {
            $raw  = Get-Content $wtSettings -Raw -Encoding UTF8
            $json = $raw | ConvertFrom-Json

            # profiles-Objekt sicherstellen
            if ($null -eq $json.profiles) {
                $json | Add-Member -MemberType NoteProperty -Name 'profiles' -Value ([PSCustomObject]@{}) -Force
            }
            # profiles.defaults sicherstellen
            if ($null -eq $json.profiles.defaults) {
                $json.profiles | Add-Member -MemberType NoteProperty -Name 'defaults' -Value ([PSCustomObject]@{}) -Force
            }
            # font-Objekt sicherstellen
            if ($null -eq $json.profiles.defaults.font) {
                $json.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'font' -Value ([PSCustomObject]@{}) -Force
            }
            # face setzen (überschreibt vorhandenen Wert)
            $json.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name 'face' -Value 'CaskaydiaCove Nerd Font' -Force

            # Zurückschreiben — Depth 20 damit keine Felder abgeschnitten werden
            $json | ConvertTo-Json -Depth 20 | Set-Content $wtSettings -Encoding UTF8
            _log "Windows Terminal Font gesetzt: CaskaydiaCove Nerd Font"
            _info "Starte Windows Terminal neu damit die Änderung sichtbar wird."
        } catch {
            _warn "Automatisches Setzen fehlgeschlagen: $_"
            _warn "Manuell: Windows Terminal → Einstellungen → Standardwerte → Darstellung → Schriftart → 'CaskaydiaCove Nerd Font'"
        }
    } else {
        _warn "Windows Terminal nicht gefunden — Font bitte nach der Installation manuell setzen:"
        _warn "Einstellungen → Standardwerte → Darstellung → Schriftart → 'CaskaydiaCove Nerd Font'"
    }

    # Aufräumen
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $unzipTo -Recurse -Force -ErrorAction SilentlyContinue
    _log "CaskaydiaCove Nerd Font installiert und registriert."
}

function _run_setup {
    New-Item -ItemType Directory -Force -Path (Split-Path $script:SetupFlag) | Out-Null
    "=== Setup gestartet: $(Get-Date) ===" | Add-Content $script:SetupLog

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       VM Bootstrap wird gestartet...     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # --- Winget-Pakete ---
    $tools = @(
        @{ id = "fastfetch-cli.fastfetch";  name = "Fastfetch"  }
        @{ id = "Starship.Starship";         name = "Starship"   }
        @{ id = "junegunn.fzf";              name = "fzf"        }
        @{ id = "ajeetdsouza.zoxide";        name = "zoxide"     }
        @{ id = "eza-community.eza";         name = "eza"        }
        @{ id = "sharkdp.fd";               name = "fd"         }
        @{ id = "BurntSushi.ripgrep.MSVC";  name = "ripgrep"    }
    )
    foreach ($t in $tools) { _winget_install $t.id $t.name }

    # --- PowerShell-Module ---
    foreach ($mod in @("Terminal-Icons", "PSReadLine", "PSFzf", "posh-git")) {
        if (!(Get-Module -ListAvailable -Name $mod -ErrorAction SilentlyContinue)) {
            _info "Installiere PowerShell-Modul $mod..."
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck 2>&1 |
                Add-Content $script:SetupLog
            _log "Modul $mod installiert."
        } else {
            _info "Modul $mod bereits vorhanden, überspringe."
        }
    }

    # --- Configs ---
    _setup_starship_config
    _setup_fastfetch_config

    # --- Nerd Font: CaskaydiaCove ---
    _install_nerd_font

    # --- Fertig ---
    New-Item -ItemType File -Force -Path $script:SetupFlag | Out-Null
    "=== Setup abgeschlossen: $(Get-Date) ===" | Add-Content $script:SetupLog

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║      Setup erfolgreich abgeschlossen!    ║" -ForegroundColor Green
    Write-Host "║   Starte ein neues Terminal zum Testen   ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

if (-not (Test-Path $script:SetupFlag)) { _run_setup }

# =============================================================================
#  PSREADLINE — History, Completion, Farben
# =============================================================================
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 100000
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+u          -Function RevertLine
    Set-PSReadLineKeyHandler -Key Ctrl+k          -Function DeleteToEnd
    Set-PSReadLineKeyHandler -Key Ctrl+d          -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineOption -Colors @{
        Command          = '#cba6f7'
        Parameter        = '#89b4fa'
        String           = '#a6e3a1'
        Operator         = '#89dceb'
        Variable         = '#cdd6f4'
        Comment          = '#585b70'
        Keyword          = '#f38ba8'
        Error            = '#f38ba8'
        Number           = '#fab387'
        Type             = '#f9e2af'
        Member           = '#89dceb'
        InlinePrediction = '#585b70'
        ListPrediction   = '#585b70'
    }
}

# =============================================================================
#  UMGEBUNGSVARIABLEN
# =============================================================================
$env:EDITOR = if (_has nvim) { 'nvim' } elseif (_has 'notepad++') { 'notepad++' } else { 'notepad' }
$env:LANG   = 'de_DE.UTF-8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$esc      = [char]27
$C_RESET  = "${esc}[0m"
$C_BOLD   = "${esc}[1m"
$C_DIM    = "${esc}[2m"
$C_CYAN   = "${esc}[36m"
$C_WHITE  = "${esc}[97m"
$C_GREEN  = "${esc}[32m"
$C_YELLOW = "${esc}[33m"

# =============================================================================
#  NAVIGATION
# =============================================================================
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function home  { Set-Location $HOME }

function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# =============================================================================
#  ALIASE — ls / eza
# =============================================================================
if (_has eza) {
    function ls  { eza --icons=auto --group-directories-first --color=auto @args }
    function l   { eza --icons=auto --group-directories-first @args }
    function ll  { eza -la --icons=auto --group-directories-first --git --header @args }
    function la  { eza -a --icons=auto --group-directories-first @args }
    function lt  { eza --tree --icons=auto --level=2 --group-directories-first @args }
    function lta { eza --tree --icons=auto --level=3 -a --group-directories-first @args }
    function lg  { eza -la --icons=auto --git --git-ignore @args }
} else {
    function ll  { Get-ChildItem -Force @args }
    function la  { Get-ChildItem -Force @args }
    function lt  { Get-ChildItem -Recurse @args }
}

# =============================================================================
#  ALIASE — cat / bat
# =============================================================================
if (_has bat) {
    function cat  { bat --style=auto --paging=never @args }
    function bcat { bat @args }
    function less { bat --paging=always @args }
}

# =============================================================================
#  ALIASE — System
# =============================================================================
function c      { Clear-Host }
Set-Alias cls   Clear-Host
function q      { exit }
function reload { & $PROFILE }
function edit-profile { & $env:EDITOR $PROFILE }

function update {
    _info "Aktualisiere alle Pakete ..."
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}
function install { winget install @args }
function search  { winget search @args }

function psg {
    param($Pattern)
    Get-Process | Where-Object { $_.Name -match $Pattern -or $_.Description -match $Pattern }
}
function ports { netstat -ano | Select-String "LISTENING" }
function df    { Get-PSDrive -PSProvider FileSystem | Format-Table Name, Used, Free, Root }
function du {
    param([string]$Path = '.')
    $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    "{0:N2} MB  {1}" -f ($size / 1MB), (Resolve-Path $Path)
}

if (_has btop) { function top { btop } }
else { function top { Get-Process | Sort-Object CPU -Descending | Select-Object -First 30 | Format-Table Name, CPU, WorkingSet -AutoSize } }

# =============================================================================
#  ALIASE — Netzwerk
# =============================================================================
function myip   { Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 5 -ErrorAction SilentlyContinue }
function myip6  { Invoke-RestMethod -Uri 'https://api6.ipify.org' -TimeoutSec 5 -ErrorAction SilentlyContinue }
function localip {
    (Get-NetIPAddress -AddressFamily IPv4 |
     Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.PrefixOrigin -ne 'WellKnown' } |
     Select-Object -First 1).IPAddress
}
function gateway { (Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -First 1).NextHop }
function wetter  { Invoke-RestMethod -Uri 'https://wttr.in/?lang=de' -TimeoutSec 5 }

# =============================================================================
#  ALIASE — Git
# =============================================================================
Set-Alias g  git
function gs   { git status @args }
function ga   { git add @args }
function gaa  { git add --all @args }
function gc   { git commit @args }
function gcm  { param($msg) git commit -m $msg }
function gp   { git push @args }
function gpl  { git pull @args }
function gl   { git log --oneline --graph --decorate --color @args }
function gll  { git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gco  { git checkout @args }
function gb   { git branch @args }
function gba  { git branch -a @args }
function gst  { git stash @args }
function gstp { git stash pop @args }

# =============================================================================
#  ALIASE — Sicherheit
# =============================================================================
function rm {
    param([switch]$Force, [switch]$Recurse, [Parameter(ValueFromRemainingArguments)][string[]]$Paths)
    if (-not $Force) {
        $answer = Read-Host "Wirklich loeschen? ($($Paths -join ', ')) [j/N]"
        if ($answer -notmatch '^[jJyY]') { Write-Host "Abgebrochen."; return }
    }
    Remove-Item @Paths -Force:$Force -Recurse:$Recurse
}

# =============================================================================
#  ALIASE — Nützliches
# =============================================================================
function h       { Get-History @args }
function hs      { param($Pattern) Get-History | Where-Object CommandLine -match $Pattern }
function now     { Get-Date -Format "HH:mm:ss" }
function nowdate { Get-Date -Format "dd.MM.yyyy" }
function week    { Get-Date -UFormat "%V" }
function path    { $env:PATH -split ';' }
function which   { param($cmd) (Get-Command $cmd -ErrorAction SilentlyContinue).Source }
function ping    { ping.exe -n 5 @args }

# =============================================================================
#  FUNKTIONEN
# =============================================================================

function extract {
    param([string]$Path)
    if (-not (Test-Path $Path)) { _err "Datei nicht gefunden: $Path"; return }
    switch -Wildcard ($Path) {
        "*.zip"  { Expand-Archive -Path $Path -DestinationPath . -Force }
        "*.7z"   { if (_has 7z) { 7z x $Path } else { _err "7-Zip nicht gefunden." } }
        "*.rar"  { if (_has 7z) { 7z x $Path } else { _err "7-Zip nicht gefunden." } }
        "*.tar*" { if (_has 7z) { 7z x $Path } else { _err "7-Zip nicht gefunden." } }
        "*.gz"   { if (_has 7z) { 7z x $Path } else { _err "7-Zip nicht gefunden." } }
        default  { _err "Unbekanntes Format: $Path" }
    }
}

function speedtest-now {
    if (_has speedtest) { speedtest }
    else { _warn "Installieren mit: winget install Ookla.Speedtest.CLI" }
}

function show_system_info {
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $disk = Get-PSDrive C
    $host_    = $env:COMPUTERNAME
    $uptime   = (Get-Date) - $os.LastBootUpTime
    $uptimeStr= "{0}d {1}h {2}m" -f [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes
    $ramUsed  = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
    $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $diskUsed = [math]::Round($disk.Used / 1GB, 1)
    $diskFree = [math]::Round($disk.Free / 1GB, 1)
    $diskPct  = [math]::Round($diskUsed / ($diskUsed + $diskFree) * 100, 0)
    $localIP  = try { (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1).IPAddress } catch { 'n/a' }
    $gw       = try { (Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -First 1).NextHop } catch { 'n/a' }
    $wan      = try { Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 3 } catch { 'n/a' }
    $cpuLoad  = try { [math]::Round($cpu.LoadPercentage, 0) } catch { 'n/a' }
    $dockerInfo = if (_has docker) {
        try { $cnt = (docker ps -q 2>$null | Measure-Object).Count; "${C_GREEN}aktiv${C_RESET} ($cnt Container)" }
        catch { "${C_YELLOW}installiert, Dienst inaktiv${C_RESET}" }
    } else { "${C_DIM}nicht installiert${C_RESET}" }

    Write-Host ""
    Write-Host "${C_CYAN}${C_BOLD}┌─── System-Info ───────────────────────────────┐${C_RESET}"
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "Hostname:",  $host_)
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "Lokale IP:", $localIP)
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "WAN-IP:",    $wan)
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "Gateway:",   $gw)
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "Uptime:",    $uptimeStr)
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "CPU:",       "$($cpu.Name.Trim()) ($cpuLoad%)")
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "RAM:",       "$ramUsed GB / $ramTotal GB")
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} ${C_WHITE}{1}${C_RESET}" -f "Disk C:",    "$diskUsed GB / $($diskUsed+$diskFree) GB ($diskPct% genutzt)")
    Write-Host ("${C_CYAN}│${C_RESET} {0,-12} {1}"                     -f "Docker:",    $dockerInfo)
    Write-Host "${C_CYAN}└───────────────────────────────────────────────┘${C_RESET}"
    Write-Host ""
}

function ps-setup-reset {
    Remove-Item -Path $script:SetupFlag -Force -ErrorAction SilentlyContinue
    Write-Host "${C_YELLOW}[!]${C_RESET} Setup-Flag geloescht. Starte ein neues Terminal um Setup erneut auszufuehren."
}

function aliases {
    Write-Host ""
    Write-Host "${C_CYAN}${C_BOLD}=== Eigene Aliase & Funktionen ===${C_RESET}"
    Write-Host "${C_BOLD}Navigation:${C_RESET}  .., ..., ...., home, mkcd"
    Write-Host "${C_BOLD}Dateien:${C_RESET}     ls/l/ll/la/lt/lta/lg, cat (bat), extract, f (suchen)"
    Write-Host "${C_BOLD}System:${C_RESET}      update, install, search, df, du, top, psg, ports"
    Write-Host "${C_BOLD}Netzwerk:${C_RESET}    myip, localip, gateway, wetter"
    Write-Host "${C_BOLD}Git:${C_RESET}         gs, ga, gc, gp, gl, gd, gco, gb, gst"
    Write-Host "${C_BOLD}Info:${C_RESET}        show_system_info, now, nowdate, week, which, path"
    Write-Host "${C_BOLD}Setup:${C_RESET}       ps-setup-reset"
    Write-Host ""
}

# =============================================================================
#  FZF — PSFzf + Farben
# =============================================================================
if ((_has fzf) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    $env:FZF_DEFAULT_OPTS = "--height=50% --layout=reverse --border=rounded --info=inline --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8 --color=info:#89dceb,prompt:#cba6f7,pointer:#f5c2e7 --color=marker:#a6e3a1,spinner:#f5c2e7,header:#fab387 --color=border:#6c7086"
    if (_has rg) { $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git"' }
    elseif (_has fd) { $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git' }
}

# =============================================================================
#  ZOXIDE — intelligenter cd-Ersatz
# =============================================================================
if (_has zoxide) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    function j  { z @args }
    function ji { zi @args }
}

# =============================================================================
#  STARSHIP — Prompt
# =============================================================================
if (_has starship) {
    Invoke-Expression (&starship init powershell)
}

# =============================================================================
#  ANZEIGE BEIM LOGIN
# =============================================================================
Clear-Host

if (_has fastfetch) {
    fastfetch
}

