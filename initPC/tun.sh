#!/bin/bash

#Assuming the ssh tunnel command was 'sudo ssh -w 16:16 -p XXXXX -i ~/.ssh/mtelecom root@XXX.XXX.XXX.XXX'
readonly TUNNEL_INTERFACE_NAME=tun16

ip link show $TUNNEL_INTERFACE_NAME

if [ $? -eq 1 ]; then
    echo "You have probably forgot to establish the ssh tunnel first of all. Try 'sudo ssh -w 16:16 -p \$REMOTE_SSH_PORT -i ~/.ssh/mtelecom root@\$REMOTE_SSH_IP'"
    exit 1
fi

REMOTE_SSH_IP=$1

if [ -z $REMOTE_SSH_IP ]; then
    echo "Remote server IP isn't set, but required"
    exit 1
fi

REMOTE_SSH_PORT=$2

if [ -z $REMOTE_SSH_PORT ]; then
    REMOTE_SSH_PORT=22
fi

GATEWAY_IP=$(ip addr show $(ip -4 route | grep -E "^default" | head -n 1 | awk '{print $5}') | grep inet | head -n 1 | awk '{print $2}' | cut -d/ -f1)
TUNNEL_REMOTE_END_IP=$(ip -4 route | grep "tun16 proto" | awk '{print $1}')
TUNNEL_LOCAL_END_IP=$(ip -4 route | grep "tun16 proto" | awk '{print $9}')

#Leaving the route not to lock ourselves out of the tunnel
ip route del $REMOTE_SSH_IP #Just for the case
ip route add $REMOTE_SSH_IP via $GATEWAY_IP
ip route del default
ip addr add $TUNNEL_LOCAL_END_IP/30 peer $TUNNEL_REMOTE_END_IP dev tun16
ip link set tun16 up
ip route add 0/0 via $TUNNEL_REMOTE_END_IP

#You may want to leave some websites outside of the tunnel
#map.ru
ip route add 37.139.43.39 via $GATEWAY_IP

#mail.ru
ip route add 89.221.239.1 via $GATEWAY_IP
ip route add 185.180.201.1 via $GATEWAY_IP
ip route add 94.100.180.59 via $GATEWAY_IP
ip route add 91.231.134.1 via $GATEWAY_IP
ip route add 94.100.180.70 via $GATEWAY_IP

#vk.ru
ip route add 185.32.250.162 via $GATEWAY_IP
ip route add 194.226.130.227 via $GATEWAY_IP # tns-counter.ru

#adriver
ip route add 37.9.64.225 via $GATEWAY_IP
ip route add  93.189.58.202 via $GATEWAY_IP
ip route add  31.131.254.97 via $GATEWAY_IP

#yastatic.net
ip route add 37.9.64.225 via $GATEWAY_IP

#uxfeedback.ru
ip route add 213.180.193.247 via $GATEWAY_IP
ip route add 95.181.182.182 via $GATEWAY_IP

#hybrid.ai
ip route add 152.42.129.85 via $GATEWAY_IP
ip route add 37.230.131.0/24 via $GATEWAY_IP

#shuclothes.ru
ip route add 188.124.36.203 via $GATEWAY_IP

