# SKILL: Networking & Telephony

## Когда использовать
Задачи по коммутаторам, VLAN, маршрутизации, IP-АТС, VoIP.

## Коммутаторы

### Типовые задачи
```
# Cisco IOS — базовые команды
enable                          # войти в привилегированный режим
configure terminal              # режим конфигурации
show interfaces status          # статус портов
show vlan brief                 # список VLAN
show mac address-table          # таблица MAC адресов
show running-config             # текущая конфигурация
copy running-config startup-config  # сохранить конфиг
```

### Настройка VLAN
```
# Создать VLAN
vlan 10
 name OFFICE

# Назначить порт в VLAN (access)
interface FastEthernet0/1
 switchport mode access
 switchport access vlan 10

# Trunk порт (для uplink)
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
```

## IP-АТС (Asterisk / FreePBX)

### Диагностика
```bash
asterisk -rvvv              # консоль Asterisk
sip show peers              # статус SIP транков и телефонов
sip show registry           # регистрация на провайдере
core show channels          # активные звонки
logger show channels        # уровни логирования
tail -f /var/log/asterisk/full  # лог в реальном времени
```

### Типовые проблемы
| Проблема | Причина | Решение |
|----------|---------|---------|
| Телефон не регистрируется | Неверный пароль/IP | Проверить sip.conf, firewall |
| Нет звука в одну сторону | NAT проблема | Настроить nat=yes, externip |
| Не проходят звонки наружу | Транк не зарегистрирован | Проверить провайдера |
| Эхо в разговоре | Echo cancellation | Включить echocancel в DAHDI |

## Сеть — диагностика проблем

### Шаги при жалобе "нет интернета"
```bash
# 1. Есть ли IP адрес?
ip a

# 2. Пингуется ли шлюз?
ping 192.168.1.1

# 3. Пингуется ли DNS?
ping 8.8.8.8

# 4. Резолвится ли DNS?
nslookup google.com

# 5. Трассировка маршрута
traceroute 8.8.8.8
```

### Полезные утилиты
```bash
iperf3 -s                   # запустить сервер для теста скорости
iperf3 -c 192.168.1.1       # тест скорости до сервера
tcpdump -i eth0 port 5060   # захват SIP трафика
wireshark                   # графический анализ трафика
```

## Шаблон документирования сети
```markdown
## Сеть: [Название объекта]
- Подсеть: 192.168.X.0/24
- Шлюз: 192.168.X.1
- DNS: 192.168.X.1, 8.8.8.8

### VLAN
| ID | Название | Назначение |
|----|----------|-----------|
| 10 | OFFICE   | Офисные ПК |
| 20 | PHONES   | IP телефоны |
| 30 | SERVERS  | Серверный сегмент |

### Оборудование
| IP | Устройство | Модель | Расположение |
|----|-----------|--------|-------------|
```
