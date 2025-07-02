#!/bin/bash
# Генерация конфигов при первом запуске
if [ ! -f /config/wg0.conf ]; then
    cp /defaults/wg0.conf /config/
    wg genkey | tee /config/server_private.key | wg pubkey > /config/server_public.key
    echo "Новый сервер сгенерирован!"
fi

# Запуск WireGuard
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf