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
# Войти в режим конфигурации (обязательно!)
enable
configure terminal

# Создать VLAN
vlan 10
 name OFFICE

# Назначить порт в VLAN (access)
interface FastEthernet0/1
 switchport mode access
 switchport access vlan 10

# Trunk порт (для uplink)
# ВАЖНО: 'allowed vlan X' ЗАМЕНЯЕТ список. Чтобы ДОБАВИТЬ — используй 'add'
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan add 10,20,30
```

## IP-АТС (Asterisk / FreePBX)

### Диагностика
```bash
asterisk -rvvv              # консоль Asterisk
core show channels          # активные звонки
logger show channels        # уровни логирования
tail -f /var/log/asterisk/full  # лог в реальном времени

# chan_sip (старый драйвер):
sip show peers              # статус SIP транков и телефонов
sip show registry           # регистрация на провайдере

# PJSIP (по умолчанию в Asterisk 12+, FreePBX):
pjsip show endpoints        # endpoint'ы (транки + телефоны)
pjsip show registrations    # исходящие регистрации (на провайдера)
pjsip show contacts         # текущие регистрации телефонов
```

### Типовые проблемы
| Проблема | Причина | Решение |
|----------|---------|---------|
| Телефон не регистрируется | Неверный пароль/IP | Проверить sip.conf, firewall |
| Нет звука в одну сторону | NAT проблема | chan_sip: `nat=force_rport,comedia`. PJSIP: `rtp_symmetric=yes`, `force_rport=yes`, `rewrite_contact=yes`. Плюс `externip` в глобале |
| Не проходят звонки наружу | Транк не зарегистрирован | Проверить провайдера |
| Эхо в разговоре | Echo cancellation | Включить echocancel в DAHDI |

## Сеть — диагностика проблем

### Шаги при жалобе "нет интернета"
```bash
# 1. Интерфейс UP?
ip link show

# 2. Есть ли IP адрес?
ip a

# 3. Настроен ли default gateway?
ip route show default

# 4. Пингуется ли шлюз?
ping 192.168.1.1

# 5. Пингуется ли внешний IP (не DNS)?
ping 8.8.8.8

# 6. Резолвится ли DNS? (dig современнее nslookup)
dig google.com
# если dig нет: host google.com  или  nslookup google.com

# 7. Трассировка маршрута
tracepath 8.8.8.8        # обычно уже установлен
# альтернативы: traceroute 8.8.8.8 (может не быть), mtr 8.8.8.8 (интерактивный)
```

### Полезные утилиты
```bash
iperf3 -s                   # запустить сервер для теста скорости
iperf3 -c 192.168.1.1       # тест скорости до сервера
tcpdump -i eth0 port 5060   # захват SIP сигнализации (без голоса!)
# Голос (RTP) идёт по UDP 10000-20000. Для диагностики звука ловить всё:
tcpdump -i eth0 -w sip.pcap 'port 5060 or portrange 10000-20000'
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
