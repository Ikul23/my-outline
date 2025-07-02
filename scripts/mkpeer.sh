#!/bin/bash
PEER_NAME=${1:-iphone}
PEER_IP="10.8.0.$((2 + $(ls /config/peer* 2>/dev/null | wc -l)))"
wg genkey | tee /config/peer_${PEER_NAME}.key | wg pubkey > /config/peer_${PEER_NAME}.pub

echo -e "\n[Peer]\nPublicKey = $(cat /config/peer_${PEER_NAME}.pub)\nAllowedIPs = ${PEER_IP}/32" >> /config/wg0.conf
echo "Новый клиент ${PEER_NAME} создан! IP: ${PEER_IP}"
qrencode -t ansiutf8 < /config/peer_${PEER_NAME}.conf