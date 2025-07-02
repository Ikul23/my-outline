FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
  wireguard \
  wireguard-tools \
  iptables \
  qrencode \
  net-tools \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/wireguard

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 51820/udp

CMD ["/start.sh"]