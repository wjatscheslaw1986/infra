table inet filter {
        chain input {
                type filter hook input priority filter; policy drop;
                iifname "lo" accept
                ip saddr 127.0.0.0/8 drop
                ip6 saddr ::1 drop
                tcp dport 212121 accept
                ct state { established, related } accept
        }

        chain forward {
                type filter hook forward priority filter; policy drop;
                ct state { established, related } accept
                iifname "eth0" oifname "tun16" ct state { established, related } accept
                iifname "tun16" oifname "eth0" accept
        }

        chain output {
                type filter hook forward priority filter; policy accept;
        }
}
table inet nat {
        chain postrouting {
                type nat hook postrouting priority filter; policy accept;
                oifname "eth0" masquerade random
        }
}