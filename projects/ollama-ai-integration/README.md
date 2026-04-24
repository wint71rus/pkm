# Ollama / AI Integration

> Создано: 2026-04-24
> Статус: активен

## Цель
Встроить локальные LLM (Ollama) в рабочие процессы — через Open WebUI для чата, через API для автоматизаций.

## Инфраструктура
- Сервер: webui.n8nwint.ru
- Open WebUI: https://webui.n8nwint.ru
- Ollama API endpoint: https://webui.n8nwint.ru/ollama/api/chat
- Текущая модель: gemma2:9b (проверить: `ollama list`)

## Связанные скиллы
- [skills/automation](../../skills/automation/SKILL.md) — пример запроса из n8n

## Задачи
- [ ] Проверить и зафиксировать реальный список моделей
- [ ] Получить API-токен в OpenWebUI (Settings → Account → API Keys)
- [ ] Попробовать разные модели под сисадминские задачи (gemma2, qwen2.5, llama3)
- [ ] Сценарий: бот в Telegram для быстрых вопросов (через n8n)
- [ ] Сценарий: RAG поверх PKM (векторная база + Ollama)

## Заметки
