cp ./host_netplanU$1.yaml /etc/netplan/0.yaml
sudo netplan apply

if [ $1 -eq "1" ]; then
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ./firewall.sh
fi
