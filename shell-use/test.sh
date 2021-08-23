#!/bin/sh

# server list
server_all_list=(\
192.168.200.68 \
192.168.200.60 \
)

date=$(date -d "today" +"%Y-%m-%d %H:%M:%S")

server_all_len=${#server_all_list[*]}

i=0
while [ $i -lt $server_all_len ]; do
  server_ip=${server_all_list[${i}]}

  echo $server_ip

  # ping server
  if ping -c 1 $server_ip > /dev/null 2>&1
  then
    echo "server : ${server_ip} ping success"
  else
    echo "server : ${server_ip} ping fail"

    error_msg=(${error_msg[*]} "server : ${server_ip} ping fail")
  fi

  # 获取cpu 使用率
  cpuIdle=$(ssh root@192.168.200.68 -i ~/.ssh/ops_rsa.pub $(top -n 1 | grep 'Cpu' | awk '{print $8}'))

  cpuUsage=$(expr 100 - "${cpuIdle[((0))]%.*}")

  eho






  let i++
done

echo ${error_msg[*]}