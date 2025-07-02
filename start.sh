bash#!/bin/bash

# Генерация ключей сервера
wg genkey | tee server_private.key | wg pubkey > server_public.key
SERVER_PRIVATE=$(cat server_private.key)
SERVER_PUBLIC=$(cat server_public.key)

# Генерация ключей клиента
wg genkey | tee client_private.key | wg pubkey > client_public.key
CLIENT_PRIVATE=$(cat client_private.key)
CLIENT_PUBLIC=$(cat client_public.key)

# Конфигурация сервера
cat > wg0.conf << EOF
[Interface]
PrivateKey = ${SERVER_PRIVATE}
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = ${CLIENT_PUBLIC}
AllowedIPs = 10.0.0.2/32
EOF

# Конфигурация клиента для iPhone
cat > client.conf << EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = 10.0.0.2/24
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = ${RENDER_EXTERNAL_HOSTNAME}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Создание QR-кода для iPhone
qrencode -t ansiutf8 < client.conf

echo "=== QR КОД ДЛЯ iPhone ==="
qrencode -t ansiutf8 < client.conf
echo "=========================="

echo "Конфигурация клиента:"
cat client.conf

# Включение IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Запуск WireGuard
wg-quick up wg0

# Показать статус
wg show

# Держать контейнер работающим
tail -f /dev/null