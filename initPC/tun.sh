#!/bin/bash

set -eux

#Assuming the ssh tunnel command was 'sudo ssh -w 16:16 -p XXXXX -i ~/.ssh/mtelecom root@XXX.XXX.XXX.XXX'
readonly TUNNEL_INTERFACE_NAME=tun16
readonly TUNNEL_REMOTE_END_IP=10.0.0.1
readonly TUNNEL_LOCAL_END_IP=10.0.0.2

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

if ! ip link show "$TUNNEL_INTERFACE_NAME" >/dev/null 2>&1; then
    echo "Tunnel interface $TUNNEL_INTERFACE_NAME doesn't exist."
    echo "Establish the SSH tunnel first:"
    echo "sudo ssh -w 16:16 -p $REMOTE_SSH_PORT -i ~/.ssh/private.key root@$REMOTE_SSH_IP"
    exit 1
fi

REMOTE_SSH_IP=${1:-}

if [ -z "$REMOTE_SSH_IP" ]; then
    echo "Remote server IP isn't set, but required"
    exit 1
fi

REMOTE_SSH_PORT=${2:-22}
GATEWAY_IP=$(ip -4 route show default | awk 'NR==1 {print $3}')
GATEWAY_DEV=$(ip -4 route show default | awk 'NR==1 {print $5}')

if [[ -z "$GATEWAY_IP" || -z "$GATEWAY_DEV" ]]; then
    echo "For this script to work, the default gateway must be present. Either restart your network service, or re-plug your ethernet cable, or re-connect to the Wi-Fi, or add the default route for the correct network interface manually."
    exit 1
fi

#Leaving the route not to lock ourselves out of the tunnel
ip route replace "$REMOTE_SSH_IP"/32 via "$GATEWAY_IP" dev "$GATEWAY_DEV"
ip addr replace "$TUNNEL_LOCAL_END_IP" peer "$TUNNEL_REMOTE_END_IP" dev "$TUNNEL_INTERFACE_NAME"
#Using /30 subnet is a compatibility hack for the case if either end of the tunnel doesn't implement RFC 3021
#ip addr replace "$TUNNEL_LOCAL_END_IP"/30 peer "$TUNNEL_REMOTE_END_IP" dev "$TUNNEL_INTERFACE_NAME"
ip link set "$TUNNEL_INTERFACE_NAME" up
ip route replace default via "$TUNNEL_REMOTE_END_IP" dev "$TUNNEL_INTERFACE_NAME"

#You may want to leave some websites outside of the tunnel
#map.ru
ip route replace 37.139.43.39 via "$GATEWAY_IP"

#mail.ru
ip route replace 89.221.239.1 via "$GATEWAY_IP"
ip route replace 185.180.201.1 via "$GATEWAY_IP"
ip route replace 94.100.180.59 via "$GATEWAY_IP"
ip route replace 91.231.134.1 via "$GATEWAY_IP"
ip route replace 94.100.180.70 via "$GATEWAY_IP"

#vk.ru
ip route replace 185.32.250.162 via "$GATEWAY_IP"
ip route replace 194.226.130.227 via "$GATEWAY_IP" # tns-counter.ru

#adriver
ip route replace 37.9.64.225 via "$GATEWAY_IP"
ip route replace  93.189.58.202 via "$GATEWAY_IP"
ip route replace  31.131.254.97 via "$GATEWAY_IP"

#yastatic.net
ip route replace 37.9.64.225 via "$GATEWAY_IP"

#uxfeedback.ru
ip route replace 213.180.193.247 via "$GATEWAY_IP"
ip route replace 95.181.182.182 via "$GATEWAY_IP"

#hybrid.ai
ip route replace 152.42.129.85 via "$GATEWAY_IP"
ip route replace 37.230.131.0/24 via "$GATEWAY_IP"

#shuclothes.ru
ip route replace 188.124.36.203 via "$GATEWAY_IP"

