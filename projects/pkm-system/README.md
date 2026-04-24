# PKM System

> Создано: 2026-04-24
> Статус: активен

## Цель
Локальная база знаний + синхронизация с GitHub, чтобы контекст не терялся между сессиями с AI.

## Связанные скиллы
- [skills/automation](../../skills/automation/SKILL.md) — если понадобятся n8n-хуки

## Ключевые файлы
- [sync.ps1](../../sync.ps1) — скрипт синхронизации
- [memory/context/facts.md](../../memory/context/facts.md) — постоянный контекст
- [memory/index/pkm-index.json](../../memory/index/pkm-index.json) — индекс

## Задачи
- [ ] Настроить Scheduled Task через `.\sync.ps1 -Setup`
- [ ] Проверить, что автосинк реально пушит раз в 30 мин
- [ ] Добавить .gitignore (если нужны исключения)
- [ ] Документировать git-хуки в sync/hooks/

## Заметки
<!-- сюда — всё, что всплывает по ходу работы -->
