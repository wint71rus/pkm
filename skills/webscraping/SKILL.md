# SKILL: Web Scraping

## Когда использовать
Задачи по парсингу сайтов, сбору данных, автоматическому поиску информации.

## Инструменты

| Инструмент | Когда использовать |
|-----------|-------------------|
| `curl` | Простой GET/POST запрос, проверка API |
| `Python + requests` | Скачать HTML страницу |
| `Python + BeautifulSoup` | Разобрать HTML, найти элементы |
| `Python + Selenium` | Сайт с JavaScript (SPA, динамика) |
| `Python + Playwright` | Современная альтернатива Selenium |
| `n8n HTTP Request` | Парсинг без кода, в воркфлоу |

## Python — базовый парсинг

### Установка
```bash
pip install requests beautifulsoup4 lxml
```

### Шаблон: скачать и разобрать страницу
```python
import requests
from bs4 import BeautifulSoup

# Заголовки чтобы сайт не блокировал
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

# Скачиваем страницу
url = "https://example.com"
response = requests.get(url, headers=headers, timeout=10)
response.encoding = 'utf-8'  # важно для русских сайтов

# Разбираем HTML
soup = BeautifulSoup(response.text, 'lxml')

# Найти элемент по тегу (безопасно — без падения, если тега нет)
h1 = soup.find('h1')
title = h1.text.strip() if h1 else ''

# Найти элемент по классу CSS
price_tag = soup.find('span', class_='price')
price = price_tag.text.strip() if price_tag else ''

# Найти все ссылки на странице
links = [a['href'] for a in soup.find_all('a', href=True)]

# Найти таблицу и получить данные
table = soup.find('table')
if table:
    for row in table.find_all('tr'):
        cells = [td.text.strip() for td in row.find_all('td')]
        print(cells)

print(f"Заголовок: {title}")
print(f"Цена: {price}")
```

### Шаблон: парсинг нескольких страниц
```python
import requests
from bs4 import BeautifulSoup
import time
import json

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}
results = []

urls = [
    "https://example.com/page/1",
    "https://example.com/page/2",
    "https://example.com/page/3",
]

def safe_text(tag):
    """Безопасно достать текст — вернёт '' если тег None."""
    return tag.text.strip() if tag else ''

for url in urls:
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'lxml')

        # Собираем данные
        items = soup.find_all('div', class_='item')
        for item in items:
            results.append({
                'name': safe_text(item.find('h2')),
                'price': safe_text(item.find('span', class_='price')),
                'url': url
            })

        print(f"Обработано: {url} — найдено {len(items)} элементов")
        time.sleep(1)  # пауза между запросами, чтобы не блокировали

    except Exception as e:
        print(f"Ошибка {url}: {e}")

# Сохранить результат
with open('results.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Итого собрано: {len(results)} записей")
```

### Шаблон: JavaScript сайт (Playwright)
```bash
pip install playwright
playwright install chromium
```

```python
from playwright.sync_api import sync_playwright
import json

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)  # headless=False чтобы видеть браузер
    page = browser.new_page()

    page.goto("https://example.com")
    page.wait_for_selector('.product-list')  # ждём загрузки элемента

    # Получить текст элемента
    title = page.locator('h1').inner_text()

    # Кликнуть кнопку
    page.click('button.load-more')
    page.wait_for_timeout(2000)  # подождать 2 секунды

    # Получить все элементы
    items = page.locator('.product-item').all()
    results = []
    for item in items:
        results.append({
            'name': item.locator('.name').inner_text(),
            'price': item.locator('.price').inner_text(),
        })

    browser.close()
    print(json.dumps(results, ensure_ascii=False, indent=2))
```

## Bash — быстрый парсинг через curl
```bash
# Скачать страницу
curl -s -A "Mozilla/5.0" "https://example.com" -o page.html

# Найти все ссылки через grep (PCRE — нужен GNU grep; на Windows использовать Git Bash/WSL)
curl -s "https://example.com" | grep -oP 'href="\K[^"]+'

# Получить JSON от API
curl -s "https://api.example.com/data" | python3 -m json.tool

# Скачать файл
curl -L -o file.pdf "https://example.com/document.pdf"
```

## n8n — парсинг без кода

### Воркфлоу: мониторинг цены товара
```
Schedule (каждый день 9:00)
  → HTTP Request: GET страница товара
  → Function: извлечь цену из HTML
  → IF: цена изменилась?
    → Telegram: уведомить об изменении
    → Google Sheets: сохранить историю цен
```

### Function нода — извлечь данные из HTML
```javascript
// Получаем HTML из предыдущей ноды
const html = $input.item.json.data;

// Простой поиск по регулярке
const priceMatch = html.match(/class="price">([^<]+)</);
const price = priceMatch ? priceMatch[1].trim() : 'не найдено';

const titleMatch = html.match(/<h1[^>]*>([^<]+)<\/h1>/);
const title = titleMatch ? titleMatch[1].trim() : 'не найдено';

return { price, title, url: $input.item.json.url };
```

## Работа с результатами

### Сохранить в CSV
```python
import csv

data = [
    {'name': 'Товар 1', 'price': '100'},
    {'name': 'Товар 2', 'price': '200'},
]

with open('output.csv', 'w', newline='', encoding='utf-8-sig') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'price'])
    writer.writeheader()
    writer.writerows(data)
```

### Сохранить в Excel
```python
# pip install openpyxl
import openpyxl

data = [
    {'name': 'Товар 1', 'price': '100', 'url': 'https://example.com/1'},
    {'name': 'Товар 2', 'price': '200', 'url': 'https://example.com/2'},
]

wb = openpyxl.Workbook()
ws = wb.active
ws.append(['Название', 'Цена', 'URL'])

for item in data:
    ws.append([item['name'], item['price'], item['url']])

wb.save('output.xlsx')
```

## Частые проблемы

| Проблема | Решение |
|---------|---------|
| 403 Forbidden | Добавить User-Agent заголовок |
| Данные не найдены | Сайт на JavaScript — использовать Playwright |
| Кириллица кракозябры | `response.encoding = 'utf-8'` |
| Блокировка по IP | Добавить `time.sleep(1-3)` между запросами |
| SSL ошибка | `requests.get(url, verify=False)` + `urllib3.disable_warnings()` |
| Сайт требует авторизацию | Использовать сессию: `requests.Session()` |

## Чеклист перед парсингом
- [ ] Проверить robots.txt сайта
- [ ] Добавить паузы между запросами
- [ ] Обернуть в try/except
- [ ] Логировать прогресс
- [ ] Сохранять промежуточные результаты
