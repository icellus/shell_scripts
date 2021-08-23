#!/bin/sh


#被监控服务器、端口列表
server_all_list=(\
192.168.200.68 \
192.168.200.60 \
)

echo "数组的元素是：${server_all_list[*]}";

date=$(date -d "today" +"%Y-%m-%d %H:%M:%S")

echo $date;
exit;

server_all_len=${#server_all_list[*]}

i=0
while  [ $i -lt $server_all_len ]
 do
    server_ip=$(echo ${server_all_list[$i]} | awk -F ':' '{print $1}')
    server_port=$(echo ${server_all_list[$i]} | awk -F ':' '{print $2}')

    is_send_msg=0

    if nc -vv -z -w 3 $server_ip $server_port > /dev/null 2>&1
    then
        #status:    0,http down    1,http ok    2,http down but ping ok
        status=1
        echo "服务器${server_ip}，端口{server_port}能够正常访问"
    else
        if nc -vv -z -w 10 $server_ip $server_port > /dev/null 2>&1 then
            status=1
            echo "服务器${server_ip}端口{server_port}能够正常访问！"
        else
            if ping -c 1 $server_ip > /dev/null 2>&1 then
                status=2
                echo "服务器${server_ip}端口{server_port}无法访问，但是能够Ping通"
                message="服务器无法访问，但是能ping通"
                is_send_msg=1
            else
                status=0x
                echo "服务器${server_ip}端口{server_port}无法访问，并且无法Ping通！"
                message="无法访问，并且无法ping"
                is_send_msg=1
            fi
        fi
        if is_send_msg=1 then
          echo "报警服务器${server_ip}报警内容： $message时间：$date " | mutt -s "服务器监控"*****************@139.com
        else
          echo "一切正常，无须发送报警消息！\n"
        fi
    fi
    let i++
 done