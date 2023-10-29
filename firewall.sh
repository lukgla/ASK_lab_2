#!/bin/bash

echo "Łukasz Głazik"

# -F flush
# Flush the selected chain (all  the chains  in  the  table  if none is given).   
# This  is  equivalent  to deleting all the rules one by one.
# -X 
# Delete the  optional  user-defined chain specified.  
# There must be no references to the chain.  
# If there are,  you  must  delete or replace the  referring  rules  before  the chain  can  be deleted.  
# The chain must be empty,  i.e.  not  contain any  rules.   
# If  no  argument  is given, it will attempt  to  delete every non-builtin 
# cleanup 
iptables -F
iptables -X
# iptables -F -t nat
# iptables -X -t nat
# iptables -F -t filter
# iptables -X -t filter

# INPUT (for packets destined to local  sockets),  
# FORWARD (for packets being  routed  through the  box), 
# OUTPUT (for locally-generated packets).

# -P, --policy chain target 
# Set the policy  for  the  built-in (non-user-defined)  chain  to  the given target.  
# The  policy  target must be either ACCEPT or DROP 

# drop all incoming packets (default rule)
iptables -P FORWARD ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# -A, --append chain rule-specification
# Append one or more  rules  to  the end  of  the selected chain.  
# -i interface
# -j target name
iptables -A INPUT -i enp0s8 -j ACCEPT
iptables -A INPUT -i enp0s3 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT # alternativly
# enable port forwarding
sysctl -w net.ipv4.ip_forward=1

# NAT

# enp0s8 - internal
# enp0s3 - external
iptables -A FORWARD -i enp0s8 -s 10.0.0.0/24 -d 0/0 -j ACCEPT
iptables -A FORWARD -i enp0s3 -s 0/0 -d 10.0.0.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -d 0/0 -j MASQUERADE


extern=$(ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
# port forwarding
iptables -A PREROUTING -t nat -i enp0s3 -p tcp -d ${extern} --dport 1234 -j DNAT --to-destination 10.0.0.2:22

iptables -A PREROUTING -t nat -i enp0s8 -p tcp -d 10.0.0.1 --dport 1234 -j DNAT --to-destination 10.0.0.2:22

iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
