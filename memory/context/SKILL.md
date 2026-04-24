# SKILL: Linux Administration

## Когда использовать
Задачи по настройке Linux серверов, сервисов, bash скриптов.

## Стиль объяснения
- Показывать команду → объяснять что она делает
- Давать рабочий пример сразу
- Указывать на что обратить внимание новичку

## Часто используемые команды

### Навигация и файлы
```bash
ls -la          # список файлов с правами и размером
cd /etc/nginx   # перейти в папку
pwd             # где я сейчас нахожусь
cat file.txt    # показать содержимое файла
nano file.txt   # редактировать файл (проще чем vim)
cp src dst      # копировать
mv src dst      # переместить / переименовать
rm -rf dir/     # удалить папку (осторожно!)
```

### Права доступа
```bash
chmod 755 script.sh     # сделать скрипт исполняемым
chown user:group file   # сменить владельца
ls -la                  # проверить права
```

### Сервисы (systemd)
```bash
systemctl status nginx      # статус сервиса
systemctl start nginx       # запустить
systemctl stop nginx        # остановить
systemctl restart nginx     # перезапустить
systemctl enable nginx      # автозапуск при старте
journalctl -u nginx -f      # логи сервиса в реальном времени
```

### Сеть
```bash
ip a                        # список интерфейсов и IP
ip r                        # таблица маршрутизации
ss -tlnp                    # открытые порты и процессы
ping 8.8.8.8                # проверка связи
curl -I https://example.com # проверить HTTP ответ
nmap -p 80,443 host         # сканировать порты
```

### Процессы
```bash
ps aux | grep nginx     # найти процесс
top / htop              # мониторинг ресурсов
kill -9 PID             # принудительно завершить процесс
```

### Логи
```bash
tail -f /var/log/syslog         # системный лог в реальном времени
tail -100 /var/log/nginx/error.log  # последние 100 строк
grep "error" /var/log/syslog    # найти ошибки
```

### Пакеты (Debian/Ubuntu)
```bash
apt update              # обновить список пакетов
apt upgrade             # обновить пакеты
apt install nginx       # установить
apt remove nginx        # удалить
apt search nginx        # найти пакет
```

## Bash скрипты — базовый шаблон
```bash
#!/bin/bash
# Описание: что делает скрипт
# Автор: Александр Манипов

set -e  # остановить при ошибке

# Переменные
SERVER="192.168.1.1"
LOG="/var/log/my-script.log"

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "Скрипт запущен"

# Проверка что запущен от root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите от root: sudo $0"
    exit 1
fi

log "Готово"
```

## Чеклист настройки нового сервера
- [ ] Обновить систему: `apt update && apt upgrade`
- [ ] Создать пользователя, добавить в sudo
- [ ] Настроить SSH ключи, отключить вход по паролю
- [ ] Настроить firewall (ufw или iptables)
- [ ] Установить fail2ban
- [ ] Настроить timezone: `timedatectl set-timezone Europe/Moscow`
- [ ] Настроить NTP синхронизацию
