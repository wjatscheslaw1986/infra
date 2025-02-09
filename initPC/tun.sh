#!/bin/bash
#Not locking ourselves out - must be via your gw, not your pc's ip
ip route add 212.192.4.86 via $1
ip addr add 10.0.0.2/30 peer 10.0.0.1 dev tun16
ip link set tun16 up
ip route del default
ip route add 0/0 via 10.0.0.1 
