FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  wireguard \
  wireguard-tools \
  iptables \
  qrencode \
  net-tools \
  iproute2 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/wireguard

# Создаем скрипт прямо в Dockerfile для избежания проблем с окончаниями строк
RUN echo '#!/bin/bash\n\
  set -e\n\
  \n\
  # Генерация ключей сервера\n\
  wg genkey | tee server_private.key | wg pubkey > server_public.key\n\
  SERVER_PRIVATE=$(cat server_private.key)\n\
  SERVER_PUBLIC=$(cat server_public.key)\n\
  \n\
  # Генерация ключей клиента\n\
  wg genkey | tee client_private.key | wg pubkey > client_public.key\n\
  CLIENT_PRIVATE=$(cat client_private.key)\n\
  CLIENT_PUBLIC=$(cat client_public.key)\n\
  \n\
  # Конфигурация сервера\n\
  cat > wg0.conf << EOF\n\
  [Interface]\n\
  PrivateKey = ${SERVER_PRIVATE}\n\
  Address = 10.0.0.1/24\n\
  ListenPort = 51820\n\
  PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE\n\
  PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE\n\
  \n\
  [Peer]\n\
  PublicKey = ${CLIENT_PUBLIC}\n\
  AllowedIPs = 10.0.0.2/32\n\
  EOF\n\
  \n\
  # Конфигурация клиента для iPhone\n\
  cat > client.conf << EOF\n\
  [Interface]\n\
  PrivateKey = ${CLIENT_PRIVATE}\n\
  Address = 10.0.0.2/24\n\
  DNS = 8.8.8.8, 1.1.1.1\n\
  \n\
  [Peer]\n\
  PublicKey = ${SERVER_PUBLIC}\n\
  Endpoint = ${RENDER_EXTERNAL_HOSTNAME}:51820\n\
  AllowedIPs = 0.0.0.0/0\n\
  PersistentKeepalive = 25\n\
  EOF\n\
  \n\
  echo "=== КОНФИГУРАЦИЯ КЛИЕНТА ==="\n\
  cat client.conf\n\
  echo "============================"\n\
  \n\
  echo "=== QR КОД ДЛЯ iPhone ==="\n\
  qrencode -t ansiutf8 < client.conf\n\
  echo "========================"\n\
  \n\
  # Включение IP forwarding\n\
  echo 1 > /proc/sys/net/ipv4/ip_forward\n\
  \n\
  # Запуск WireGuard\n\
  wg-quick up wg0\n\
  \n\
  echo "WireGuard запущен!"\n\
  wg show\n\
  \n\
  # Держать контейнер работающим\n\
  tail -f /dev/null' > /start.sh && chmod +x /start.sh

EXPOSE 51820/udp

CMD ["/start.sh"]