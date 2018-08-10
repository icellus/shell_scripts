#!/bin/bash

# todo 检测目录或文件是否有效
project_dir="/d/project_folder/project_name"
online_version="svn://192.168.0.2/xxx/xxx/xxx"
username=""
password=""

# 检验svn是否存在
if ! [ -x "$(command -v svn)" ]; then
  echo 'Error: svn is not installed.' >&2
  exit 1
fi
# 项目根目录
working_copy_path="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Working Copy Root Path/p' | awk '{print $5}')"
# 关联路径
relative_url="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Relative/p' | awk '{print $3}' | sed 's/^\^//')"


# svn log -r {2018-06-08}:{2018-08-06} -q -v --search cuipw | sed -e '/cuipw |/d' -e '/Changed paths:/d' -e '/---/d' | awk '{print $2}'

# 去重复
# svn log -r {2018-06-08}:{2018-08-06} -q -v --search cuipw | sed -e '/cuipw |/d' -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq

# todo 存入数组或者变量
log_array="$(svn log ${project_dir} -r {2018-06-08}:{2018-08-06} -q -v --search ${username}  --username ${username} --password ${password} | sed -e "/${username} |/d" -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq)"


update_dir="update"$(date "+%Y_%m_%d_%H_%M")
# 当前文件夹下 创建 update 文件夹 用于存储有更新的文件
if ! [[ -d ${update_dir} ]]; then
	mkdir ${update_dir}
fi

#echo "数组的元素为: ${log_array[*]}"
# echo $relative_url
# 
# 创建 文件夹
for loop in ${log_array}
do
	# 文件绝对路径
    file=${project_dir}${loop#${relative_url}*}

    if [ -f ${file} ]; then
        # cp --parents 保留源路径
    	cp --parents ${file} ${update_dir}
    elif [ -d ${file} ]; then
    	mkdir -p ${update_dir}${file}
    fi
done

# 复制出来的文件使用的是全路径， 剪切出来。
mkdir update_file
# windows is a little stupid ! So I use 'mv ' second times .
mv ${update_dir}${project_dir} update_file/

rm -rf ${update_dir}  && mkdir ${update_dir}

mv update_file/*/* ${update_dir}
rm -rf update_file/


# copy the .svn file
#cp -r ${project_dir}"/.svn" $update_dir
# until now,you have get the all updated file's copy

# checkout the online version
svn checkout -q ${online_version} online_version  --username ${username} --password ${password}

# create an empty git repository
if ! [ -x "$(command -v git)" ]; then
  cp -rf ${update_dir}"/*" online_version
  echo 'Error: git is not installed.' >&2
  exit 1
fi
cd online_version
git init
git add .

git commit -m 'init repository' -q

cd ../ && cp -rf ${update_dir}"/*" online_version && cd online_version
git add .

echo "please check the diff with your local and the online version, and do the edit you need"




# I'm so sorry,my script has throw a exception
