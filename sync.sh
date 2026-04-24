#!/usr/bin/env bash
# sync.sh — Синхронизация PKM
# Использование: ./sync.sh [--setup | --push | --pull | --backup]

PKM_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOTE_URL=""  # Заполни: git@github.com:username/pkm-private.git

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[PKM]${NC} $1"; }
warn() { echo -e "${YELLOW}[PKM]${NC} $1"; }
err()  { echo -e "${RED}[PKM]${NC} $1"; }

setup() {
  log "Инициализация PKM..."
  cd "$PKM_DIR"

  # Git init
  if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "init: PKM structure"
    log "Git репозиторий создан"
  fi

  # Добавить remote если задан
  if [ -n "$REMOTE_URL" ]; then
    git remote add origin "$REMOTE_URL" 2>/dev/null || true
    log "Remote добавлен: $REMOTE_URL"
  fi

  # Cron для автосинхронизации каждые 30 минут
  CRON_JOB="*/30 * * * * cd $PKM_DIR && ./sync.sh --push >> /tmp/pkm-sync.log 2>&1"
  (crontab -l 2>/dev/null | grep -v "pkm.*sync"; echo "$CRON_JOB") | crontab -
  log "Автосинхронизация настроена (каждые 30 мин)"

  log "✓ PKM готов!"
}

push() {
  cd "$PKM_DIR"
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
  
  git add -A
  if git diff --cached --quiet; then
    warn "Нет изменений для синхронизации"
    return 0
  fi

  git commit -m "sync: $TIMESTAMP"

  if [ -n "$REMOTE_URL" ] || git remote | grep -q origin; then
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    log "✓ Синхронизировано с remote: $TIMESTAMP"
  else
    log "✓ Локальный коммит: $TIMESTAMP"
  fi
}

pull() {
  cd "$PKM_DIR"
  git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
  log "✓ Получены обновления"
}

backup() {
  BACKUP_NAME="pkm-backup-$(date '+%Y%m%d-%H%M').tar.gz"
  BACKUP_DIR="${HOME}/pkm-backups"
  mkdir -p "$BACKUP_DIR"
  
  tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    --exclude="$PKM_DIR/.git" \
    -C "$(dirname "$PKM_DIR")" \
    "$(basename "$PKM_DIR")"
  
  log "✓ Бэкап создан: $BACKUP_DIR/$BACKUP_NAME"

  # Удалить бэкапы старше 30 дней
  find "$BACKUP_DIR" -name "pkm-backup-*.tar.gz" -mtime +30 -delete
}

new_session() {
  DATE=$(date '+%Y-%m-%d')
  TIME=$(date '+%H-%M')
  SESSION_FILE="$PKM_DIR/memory/sessions/${DATE}-${TIME}.md"
  
  sed "s/{{DATE}}/$DATE/g; s/{{TIME}}/$TIME/g" \
    "$PKM_DIR/memory/sessions/_template.md" > "$SESSION_FILE"
  
  log "Сессия создана: $SESSION_FILE"
  echo "$SESSION_FILE"
}

case "${1:-}" in
  --setup)   setup ;;
  --push)    push ;;
  --pull)    pull ;;
  --backup)  backup ;;
  --session) new_session ;;
  *)
    echo "PKM Sync Tool"
    echo ""
    echo "Команды:"
    echo "  --setup    Первоначальная настройка (git, cron)"
    echo "  --push     Сохранить и синхронизировать изменения"
    echo "  --pull     Получить изменения с remote"
    echo "  --backup   Создать архивный бэкап"
    echo "  --session  Создать новый файл сессии"
    ;;
esac
