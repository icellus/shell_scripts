#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/05/24 00:00
# @Desc    : 定时任务，以需要的时间间隔执行某个命令
# @File    : task.py
# @Software: PyCharm

import time, os
from monitor import task

def roll_back(cmd, inc = 60):
    while True:
        #执行方法，函数
        task()
        time.sleep(inc)

roll_back("echo %time%", 30)