# Используем базовый образ WireGuard
FROM linuxserver/wireguard:latest

# Устанавливаем зависимости
RUN apk add --no-cache bash qrencode

# Копируем скрипты конфигурации
COPY ./config /config
COPY ./scripts /scripts

# Даем права на исполнение скриптов
RUN chmod +x /scripts/*.sh

# Открываем порт для WireGuard
EXPOSE 51820/udp

# Запускаем скрипт при старте контейнера
CMD ["/bin/bash", "/scripts/start.sh"]