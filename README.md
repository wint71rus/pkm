# PKM — Personal Knowledge Management

Локальная база знаний с синхронизацией для работы с AI-агентами.

## Структура

```
C:\pkm\
├── docs/                   # Маркдауны (пока пустые, заготовка)
│   ├── notes/              # Быстрые заметки и идеи
│   ├── projects/           # Проекты (один проект = одна папка)
│   └── archive/            # Завершённые / неактивные
│
├── skills/                 # Скиллы для агентов
│   ├── automation/         # n8n, AI-агенты, Ollama
│   ├── networking/         # Коммутаторы, VLAN, Asterisk, VoIP
│   └── webscraping/        # Парсинг сайтов, Python + BeautifulSoup/Playwright
│
├── agents/                 # Конфигурации агентов
│   ├── prompts/            # Системные промпты
│   ├── configs/            # JSON/YAML конфиги (пусто)
│   └── tools/              # Скрипты и инструменты (пусто)
│
├── memory/                 # Память и контекст
│   ├── sessions/           # Логи сессий с AI (по дате)
│   ├── context/            # Активный контекст (facts.md)
│   └── index/              # Индексы для быстрого поиска (pkm-index.json)
│
└── sync/                   # Синхронизация
    ├── hooks/              # Git-хуки (пусто)
    └── export/             # Экспорты для внешних сервисов (пусто)
```

## Быстрый старт (Windows / PowerShell)

```powershell
# Первичная инициализация (создаёт Scheduled Task на автосинк)
.\sync.ps1 -Setup

# Закоммитить и запушить изменения
.\sync.ps1 -Push

# Подтянуть изменения с GitHub
.\sync.ps1 -Pull

# Сделать бэкап-архив
.\sync.ps1 -Backup

# Создать новый лог сессии
.\sync.ps1 -Session
```

Remote: `git@github.com:wint71rus/pkm.git`

## Соглашения по именованию

- Заметки: `YYYY-MM-DD-название.md`
- Проекты: `project-name/README.md`
- Сессии: `sessions/YYYY-MM-DD-HH-MM.md`
- Скиллы: `SKILL.md` (всегда uppercase)
