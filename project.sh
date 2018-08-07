#!/bin/bash

# todo 检测目录或文件是否有效
project_dir="/d/www/cm_profile"

#项目根目录
working_copy_path="$(svn info ${project_dir} | sed -n '/Working Copy Root Path/p' | awk '{print $5}')"
# 关联路径
relative_url="$(svn info ${project_dir} | sed -n '/Relative/p' | awk '{print $3}' | sed 's/^\^//')"


# 检验svn 和 git 是否存在
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v svn)" ]; then
  echo 'Error: svn is not installed.' >&2
  exit 1
fi

# svn log -r {2018-06-08}:{2018-08-06} -q -v --search cuipw | sed -e '/cuipw |/d' -e '/Changed paths:/d' -e '/---/d' | awk '{print $2}'

# 去重复
# svn log -r {2018-06-08}:{2018-08-06} -q -v --search cuipw | sed -e '/cuipw |/d' -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq

# todo 存入数组或者变量
log_array="$(svn log ${project_dir} -r {2018-06-08}:{2018-08-06} -q -v --search cuipw | sed -e '/cuipw |/d' -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq)"

# 当前文件夹下 创建 update 文件夹 用于存储有更新的文件
if ! [[ -d update ]]; then
	mkdir update
fi

#echo "数组的元素为: ${log_array[*]}"
# echo $relative_url
# 
# 创建 文件夹
for loop in ${log_array}
do
	# 文件绝对路径
    file=${project_dir}${loop#${relative_url}*}

    if [ -f $file ]; then
    	cp --parents $file update
    elif [ -d $file ]; then
    	echo $file" is a dir"
    fi
done

# 复制出来的文件使用的是全路径， 剪切出来。
mkdir update_file
# windows is a little stupid ! So I use 'mv ' second times .
# echo "update"${project_dir}"/*"
mv "update"${project_dir} update_file/
rm -rf update

mkdir test
mv update_file/*/* test

rm -rf update_file/
# I'm so sorry,my script has throw a exception

