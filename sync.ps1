param(
    [switch]$Setup,
    [switch]$Commit,
    [switch]$Push,
    [switch]$Pull,
    [switch]$Backup,
    [switch]$Session
)
$PKM_DIR = "C:\pkm"
$REMOTE_URL = "git@github.com:wint71rus/pkm.git"

function log($msg)  { Write-Host "[PKM] $msg" -ForegroundColor Green }
function warn($msg) { Write-Host "[PKM] $msg" -ForegroundColor Yellow }

function Setup-PKM {
    Set-Location $PKM_DIR
    if (-not (Test-Path ".git")) {
        git init
        git add .
        git commit -m "init: PKM structure"
        log "Git репозиторий создан"
    }
    # Scheduled Task теперь делает только локальный коммит (без пуша)
    $action   = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -File `"$PKM_DIR\sync.ps1`" -Commit"
    $trigger  = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -Once -At (Get-Date)
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName "PKM-AutoSync" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    log "Готово! Автокоммит каждые 30 мин (локально, без пуша). Пушить вручную: .\sync.ps1 -Push"
}

function Commit-PKM {
    Set-Location $PKM_DIR
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
    git add -A
    if (-not (git status --porcelain)) { warn "Нет изменений"; return $false }
    git commit -m "sync: $ts" | Out-Null
    log "Коммит: $ts"
    return $true
}

function Push-PKM {
    Commit-PKM | Out-Null
    Set-Location $PKM_DIR
    $ahead = (git rev-list --count '@{u}..HEAD' 2>$null)
    if ($ahead -eq "0" -or $ahead -eq $null) { warn "Нечего пушить"; return }
    if ($REMOTE_URL -ne "") { git push origin main 2>$null }
    log "Отправлено на remote: $ahead коммит(ов)"
}

function Pull-PKM {
    Set-Location $PKM_DIR
    git pull origin main 2>$null
    log "Изменения получены"
}

function Backup-PKM {
    $dir = "$HOME\pkm-backups"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $name = "pkm-backup-$(Get-Date -Format 'yyyyMMdd-HHmm').zip"
    Compress-Archive -Path "$PKM_DIR\*" -DestinationPath "$dir\$name" -Force
    log "Бэкап: $dir\$name"
}

function New-Session {
    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH-mm"
    $file = "$PKM_DIR\memory\sessions\$date-$time.md"
    $templatePath = "$PKM_DIR\memory\sessions\_template.md"

    if (Test-Path $templatePath) {
        $content = (Get-Content $templatePath -Raw -Encoding UTF8) -replace '\{\{DATE\}\}', $date -replace '\{\{TIME\}\}', $time
    } else {
        $content = "# Сессия: $date $time`n`n## Цель`n`n## Решения`n`n## Задачи`n- [ ] "
    }

    Set-Content -Path $file -Value $content -Encoding UTF8
    log "Сессия: $file"
    if (Get-Command "code" -ErrorAction SilentlyContinue) { code $file } else { notepad $file }
}

if     ($Setup)   { Setup-PKM }
elseif ($Commit)  { Commit-PKM | Out-Null }
elseif ($Push)    { Push-PKM }
elseif ($Pull)    { Pull-PKM }
elseif ($Backup)  { Backup-PKM }
elseif ($Session) { New-Session }
else {
    Write-Host "Использование: .\sync.ps1 -Setup | -Commit | -Push | -Pull | -Backup | -Session" -ForegroundColor Cyan
    Write-Host "  -Setup    регистрирует Scheduled Task (автокоммит каждые 30 мин)" -ForegroundColor Gray
    Write-Host "  -Commit   локальный коммит (без пуша) — это делает автотаск" -ForegroundColor Gray
    Write-Host "  -Push     коммит + пуш на remote (вручную, когда готов)" -ForegroundColor Gray
    Write-Host "  -Pull     git pull origin main" -ForegroundColor Gray
    Write-Host "  -Backup   zip-архив всего PKM в ~\pkm-backups\" -ForegroundColor Gray
    Write-Host "  -Session  создать новый лог сессии по шаблону" -ForegroundColor Gray
}
