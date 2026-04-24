param([switch]$Setup,[switch]$Push,[switch]$Pull,[switch]$Backup,[switch]$Session)
$PKM_DIR = "C:\pkm"
$REMOTE_URL = "git@github.com:ВАШ_ЛОГИН/pkm.git"
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
    $action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -File `"$PKM_DIR\sync.ps1`" -Push"
    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -Once -At (Get-Date)
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName "PKM-AutoSync" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    log "Готово! Автосинхронизация каждые 30 мин"
}

function Push-PKM {
    Set-Location $PKM_DIR
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
    git add -A
    if (-not (git status --porcelain)) { warn "Нет изменений"; return }
    git commit -m "sync: $ts"
    if ($REMOTE_URL -ne "") { git push origin main 2>$null }
    log "Сохранено: $ts"
}

function Pull-PKM {
    Set-Location $PKM_DIR
    git pull origin main 2>$null
    log "Получены обновления"
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
    $content = "# Сессия: $date $time`n`n## Цель`n`n## Решения`n`n## Задачи`n- [ ] "
    Set-Content -Path $file -Value $content -Encoding UTF8
    log "Сессия: $file"
    if (Get-Command "code" -ErrorAction SilentlyContinue) { code $file } else { notepad $file }
}

if     ($Setup)   { Setup-PKM }
elseif ($Push)    { Push-PKM }
elseif ($Pull)    { Pull-PKM }
elseif ($Backup)  { Backup-PKM }
elseif ($Session) { New-Session }
else { Write-Host "Использование: .\sync.ps1 -Setup | -Push | -Pull | -Backup | -Session" -ForegroundColor Cyan }
