#!/usr/bin/env bash

#constants
wan_i=$(ip route | awk '$1 == "default" {print $5}') #find name of our WAN interface
echo "init_fw.sh : WAN network interface is " $wan_i

#nft flush ruleset

#not to lock yourself out
nft add rule inet filter input ! iifname $wan_i tcp dport 58881 ct state new accept

#general policies
#nft add rule inet filter input drop
#nft add rule inet filter forward drop
#nft add rule inet filter output accept

#loopback
nft add rule inet filter input iifname "lo" accept
nft add rule inet filter input ip saddr 127.0.0.0/8 drop
nft add rule inet filter input ip6 saddr ::1/128 drop

#Let ourselves browse Internet
nft add rule inet filter input ct state {related, established} accept
nft add rule inet filter forward ct state {related, established} accept

#Defend from SYN flood
nft add rule inet filter input ! iifname $wan_i tcp flags syn limit rate 1/second accept
nft add rule inet filter input tcp flags syn drop

#Defend from port scanners
nft add rule inet filter input ! iifname $wan_i tcp flags & (syn|ack|fin|rst) == rst limit rate 1/second accept
nft add rule inet filter input tcp flags & (syn|ack|fin|rst) == rst drop

nft add rule inet filter input ip saddr 66.66.66.0/24 tcp dport 53 ct state new accept
nft add rule inet filter input ip saddr 66.66.66.0/24 udp dport 53 ct state new accept

#Defence against ping of death
nft add rule inet filter input ! iifname $wan_i ip protocol icmp icmp type echo-request limit rate 1/second accept
nft add rule inet filter input ip protocol icmp icmp type echo-request drop

#Allow routing
nft add rule inet nat POSTROUTING oifname $wan_i masquerade random
nft add rule inet nat POSTROUTING oifname tun15 masquerade random

#Access to DB
nft add rule inet filter input ip saddr 66.66.66.0/24 tcp dport 15432 accept

#SSH tunneling
nft add rule inet filter forward iifname tun15 oifname eth1 ct state {related, established} accept
nft add rule inet filter forward iifname eth1 oifname tun15 accept

#Casual routing
nft add rule inet filter forward iifname wlan0 oifname eth0 accept
nft add rule inet filter forward iifname eth0 oifname wlan0 ct state {related, established} accept
nft add rule inet filter forward iifname eth1 oifname eth0 accept
nft add rule inet filter forward iifname eth0 oifname eth1 ct state {related, established} accept
