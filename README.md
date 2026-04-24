# PKM — Personal Knowledge Management

Локальная база знаний с синхронизацией для работы с AI-агентами.

## Структура

```
~/pkm/
├── docs/               # Маркдауны
│   ├── notes/          # Быстрые заметки и идеи
│   ├── projects/       # Проекты (один проект = одна папка)
│   └── archive/        # Завершённые / неактивные
│
├── skills/             # Скиллы для агентов
│   ├── writing/        # Написание текстов, редактирование
│   ├── coding/         # Программирование, архитектура
│   └── research/       # Исследования, анализ
│
├── agents/             # Конфигурации агентов
│   ├── prompts/        # Системные промпты
│   ├── configs/        # JSON/YAML конфиги
│   └── tools/          # Скрипты и инструменты
│
├── memory/             # Память и контекст
│   ├── sessions/       # Логи сессий с AI (по дате)
│   ├── context/        # Активный контекст (facts.md, prefs.md)
│   └── index/          # Индексы для быстрого поиска
│
└── sync/               # Синхронизация
    ├── hooks/          # Git-хуки
    └── export/         # Экспорты для внешних сервисов
```

## Быстрый старт

```bash
# Инициализация git
cd ~/pkm && git init

# Первый коммит
git add . && git commit -m "init: PKM structure"

# Автосинхронизация
chmod +x sync.sh && ./sync.sh --setup
```

## Соглашения по именованию

- Заметки: `YYYY-MM-DD-название.md`
- Проекты: `project-name/README.md`
- Сессии: `sessions/YYYY-MM-DD-HH-MM.md`
- Скиллы: `SKILL.md` (всегда uppercase)
