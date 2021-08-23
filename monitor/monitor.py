#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/05/24 00:00
# @Desc    : 服务器监控代码
# @File    : monitor.py
# @Software: PyCharm

import pexpect
import re

import time
import threading

server_list = [
    "192.168.200.60",
    "192.168.200.68",
]

"""
ssh login
"""
def ssh_command(user, host, password, command):
    ssh_new_key = 'Are you sure you want to continue connecting'
    child = pexpect.spawn('ssh -l %s %s %s' % (user, host, command))
    i = child.expect([pexpect.TIMEOUT, ssh_new_key, 'password: '])
    if i == 0:
        print('ERROR!')
        print('SSH could not login. Here is what SSH said:')
        print(child.before, child.after)
        return None
    if i == 1:
        child.sendline('yes')
        child.expect('password: ')
        i = child.expect([pexpect.TIMEOUT, 'password: '])
        if i == 0:
            print('ERROR!')
            print('SSH could not login. Here is what SSH said:')
            print(child.before, child.after)
            return None
    child.sendline(password)
    return child


"""
内存监控
"""
def mem_info():

    child = ssh_command("root", "192.168.200.68", "c$YycswkQa9Q", "cat /proc/meminfo")
    child.expect(pexpect.EOF)

    # print(child.before)
    # print("\n\n???\n")
    # print(child.after)
    mem = child.before
    mem = mem.decode('utf-8')
    mem_values = re.findall("(\d+)\ kB", mem)
    MemTotal = mem_values[0]
    MemFree = mem_values[1]
    Buffers = mem_values[2]
    Cached = mem_values[3]
    SwapCached=mem_values[4]
    SwapTotal = mem_values[13]
    SwapFree = mem_values[14]
    print('******************************内存监控*********************************')
    print("*******************时间：", time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), "******************")
    print("总内存：",MemTotal)
    print("空闲内存：", MemFree)
    print("给文件的缓冲大小:",Buffers)
    print("高速缓冲存储器使用的大小:", Cached)
    print("被高速缓冲存储用的交换空间大小:", SwapCached)
    print("给文件的缓冲大小:", Buffers)
    if int(SwapTotal) == 0:
        print(u"交换内存总共为：0")
    else:
        Rate_Swap = 100 - 100*int(SwapFree)/float(SwapTotal)
        print(u"交换内存利用率：", Rate_Swap)
    Free_Mem = int(MemFree) + int(Buffers) + int(Cached)
    Used_Mem = int(MemTotal) - Free_Mem
    Rate_Mem = 100*Used_Mem/float(MemTotal)
    print(u"内存利用率：", str("%.2f" % Rate_Mem), "%")
#


"""
task
"""
def task():
    try:
        threads = []
        t1 = threading.Thread(target=mem_info)
        threads.append(t1)
        # t2 = threading.Thread(target=vm_stat_info)
        # threads.append(t2)
        # t3 = threading.Thread(target=cpu_info)
        # threads.append(t3)
        # t4 = threading.Thread(target=load_stat)
        # threads.append(t4)
        # t5 = threading.Thread(target=ionetwork)
        # threads.append(t5)
        # t6 = threading.Thread(target=disk_stat)
        # threads.append(t6)
        # t7 = threading.Thread(target=getComStr)
        # threads.append(t7)
        # t8 = threading.Thread(target=cpu)
        # threads.append(t8)
        for n in range(len(threads)):
            threads[n].start()
    except Exception as e:
        print(str(e))