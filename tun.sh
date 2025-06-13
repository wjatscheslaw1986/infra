#!/bin/bash
#You definitely don't want to lock yourself out of the tunnel. This is why you leave this route
ip route del 212.192.4.86
#ip route add 212.192.4.86 via 10.5.5.1
ip route add 212.192.4.86 via $1
ip route add 172.16.200.1 via $1 #vpn
ip route del default
ip addr add 10.0.0.2/30 peer 10.0.0.1 dev tun16
ip link set tun16 up
#Old ifconfig obsolete style commented out
#route add default gw 10.0.1.1 tun13
ip route add 0/0 via 10.0.0.1 
ip route add 78.111.81.140 via 172.16.200.1
ip route add 78.111.81.133 via 172.16.200.1 #conf
ip route add 78.111.81.139 via 172.16.200.1 #mail
ip route add 192.168.173.9 via 172.16.200.1 #ssh
