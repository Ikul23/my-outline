FROM linuxserver/wireguard:latest

# Устанавливаем зависимости с включением testing-репозитория
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk update && \
  apk add --no-cache bash qrencode

# Остальная часть файла без изменений
COPY ./config /config
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh
EXPOSE 51820/udp
CMD ["/bin/bash", "/scripts/start.sh"]