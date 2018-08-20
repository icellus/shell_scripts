#!/bin/bash

# todo 检测目录或文件是否有效
project_dir="/d/project_folder/project_name"
online_version="svn://192.168.0.2/xxx/xxx/xxx"

# account
username=""
password=""

# 检索条件
search_user=""  # 检索用户 default:当前用户
start_time=""   # 开始时间 default:3天前  格式：  {2018-08-03}
end_time=""     # 结束时间 default:当前时间

if [[ -z "${username}" || -z "${password}" ]]; then
    echo 'please offer your username and password' >&2
    exit 1
fi

if [ -z "${search_user}" ]; then
    search_user="${username}"
fi
if [ -z "${start_time}" ]; then
    start_time="{$(date -d -3day "+%Y-%m-%d")}"
fi
if [ -z "${end_time}" ]; then
    end_time="HEAD"
fi
echo -e "Params initialization completed. start to get svn log......\n"

# 检验svn是否存在
if ! [ -x "$(command -v svn)" ]; then
  echo 'Error: svn is not installed.' >&2
  exit 1
fi
# 项目根目录
working_copy_path="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Working Copy Root Path/p' | awk '{print $5}')"
# 关联路径
relative_url="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Relative/p' | awk '{print $3}' | sed 's/^\^//')"

# svn log -r {2018-06-08}:{2018-08-06} -q -v --search ${username} | sed -e '/${username} |/d' -e '/Changed paths:/d' -e '/---/d' | awk '{print $2}'
# 去重复
# svn log -r {2018-06-08}:{2018-08-06} -q -v --search ${username} | sed -e '/${username} |/d' -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq

# todo 存入数组或者变量
log_array="$(svn log ${project_dir} -r ${start_time}:${end_time} -q -v --search ${username} --username ${username} --password ${password} | sed -e "/${username} |/d" -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq)"
#echo "数组的元素为: ${log_array[*]}"

update_dir="update"$(date "+%Y_%m_%d_%H_%M")
# 当前文件夹下 创建 update 文件夹 用于存储有更新的文件
if ! [[ -d ${update_dir} ]]; then
	mkdir ${update_dir}
fi

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

# 检验svn log是否存在
if  [ "$(ls -A ${update_dir})" == "" ]; then
  echo 'The svn log search result is empty.' >&2
  exit 1
fi

# 复制出来的文件使用的是全路径， 剪切出来。
# can't use mv ${update_dir}${project_dir}"/*" update_file/ don't ask me why
mkdir update_file
mv ${update_dir}${project_dir}/* update_file/

rm -rf ${update_dir}/*

mv update_file/* ${update_dir}
rm -rf update_file/
echo -e "svn log have checked successfully,start to checkout online_version,please wait a moment...... \n"

# todo 交互式处理剩下的逻辑
# copy the .svn file
#cp -r ${project_dir}"/.svn" $update_dir
# until now,you have get the all updated file's copy

# checkout the online version
# todo 只检出有变更的文件夹
online_version_dir="online_version_"$(date "+%Y_%m_%d_%H_%M")
svn checkout -q ${online_version} ${online_version_dir}  --username ${username} --password ${password}

if ! [ -x "$(command -v git)" ]; then
  cp -rf ${update_dir}/* ${online_version_dir}
  echo 'Error: git is not installed.' >&2
  exit 1
fi

echo -e "online_version have checked out,try to init a git repository...... \n"
# create an empty git repository
cd ${online_version_dir}
git init
echo -e "\n"
# first commit  add the whole online_version
git add .
git commit -m 'init repository' -q
echo -e "\n"

cd ../
cp -rf ${update_dir}/* ${online_version_dir}
cd ${online_version_dir}
git add .

echo "please check the diff with your local and the online version, and do the edit you need"


# I'm so sorry,my script has throw a exception

