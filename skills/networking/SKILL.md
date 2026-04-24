# SKILL: Automation (n8n, AI Agents)

## Когда использовать
Задачи по n8n воркфлоу, интеграциям, AI агентам, локальным автоматизациям.

## n8n — основы

### Структура воркфлоу
Триггер → Обработка → Действие

Примеры триггеров:
- Webhook (HTTP запрос извне)
- Schedule (по расписанию, как cron)
- Telegram сообщение
- Новый файл в папке

### Типовые паттерны

**Мониторинг сервера → уведомление в Telegram**
```
Schedule (каждые 5 мин)
  → SSH: проверить disk/cpu/memory
  → IF: если > порога
    → Telegram: отправить алерт
```

### Запрос к Ollama API из n8n
```javascript
const response = await fetch('https://webui.n8nwint.ru/ollama/api/chat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    model: 'gemma3:9b',
    messages: [
      { role: 'system', content: 'Ты помощник сисадмина. Кратко и по делу.' },
      { role: 'user', content: $input.item.json.message }
    ],
    stream: false
  })
});
const data = await response.json();
return { response: data.message.content };
```

## Идеи воркфлоу для сисадмина
- Мониторинг серверов → Telegram алерты
- Еженедельный отчёт по дискам
- Бэкап конфигов коммутаторов
- Уведомление когда сайт недоступен
- Парсинг логов Asterisk → статистика звонков

## Чеклист нового воркфлоу
- [ ] Добавить Error Trigger ноду
- [ ] Уведомление при падении воркфлоу
- [ ] Задокументировать назначение
- [ ] Протестировать на реальных данных
