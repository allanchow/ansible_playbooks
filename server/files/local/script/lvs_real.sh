#!/bin/bash
#FileName: lvs_real
#Description : start realserver
VIP0=192.168.103.201
case "$1" in
start)
  echo "start LVS of REALServer"
  /sbin/ifconfig lo:0 $VIP0 broadcast $VIP0 netmask 255.255.255.255 up
#  /sbin/ip route add table local $VIP0 dev lo
  echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
  echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
  echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
  echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
  ;;
stop)
  /sbin/ifconfig lo:0 down
#  /sbin/ip route del table local $VIP0 dev lo
  echo "close LVS Directorserver"
  echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
  echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
  echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
  echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
  ;;
*)
  echo "Usage: $0 {start|stop}"
exit 1
esac
