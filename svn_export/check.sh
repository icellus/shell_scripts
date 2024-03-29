#!/bin/bash
#
# svn export script

##### 配置项 开始 #####
#
# 必填项：
#   project_dir     当前项目的本地路径(绝对路径)
#   online_version  线上版本的svn地址
#
#   username        svn username
#   password        svn  password
#
# 选填项：
#   search_user     检索用户 default:当前用户
#   start_time      开始时间 default:3天前  格式：  {2018-08-03}
#   end_time        结束时间 default:当前时间
###################################################
project_dir="/d/project_folder/project_name"
online_version="svn://192.168.0.2/xxx/xxx/xxx"

username=""
password=""

search_user=""
start_time=""
end_time=""
##### 配置项 结束  #####

#--------------------------------------------
#   script start
#
#--------------------------------------------
# todo 检测目录或文件是否有效
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

# svn update
svn update ${project_dir} --username ${username} --password ${password}

# 项目根目录
#working_copy_path="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Working Copy Root Path/p' | awk '{print $5}')"
# svn relative url
relative_url="$(svn info ${project_dir} --username ${username} --password ${password} | sed -n '/Relative/p' | awk '{print $3}' | sed 's/^\^//')"

# svn log -r {2018-06-08}:{2018-08-06} -q -v --search ${username} | sed -e '/${username} |/d' -e '/Changed paths:/d' -e '/---/d' | awk '{print $2}'
# 去重复
# svn log -r {2018-06-08}:{2018-08-06} -q -v --search ${username} | sed -e '/${username} |/d' -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq

# 将svn log 存入数组
log_array="$(svn log ${project_dir} -r ${start_time}:${end_time} -q -v --search ${username} --username ${username} --password ${password} | sed -e "/${username} |/d" -e '/Changed paths:/d' -e '/---/d' | sort -n | awk '{print $2}' | uniq)"
#echo "数组的元素为: ${log_array[*]}"

update_dir="update"$(date "+%Y_%m_%d_%H_%M")
# 当前文件夹下 创建 update 文件夹 用于存储有更新的文件
if ! [ -d ${update_dir} ]; then
	mkdir ${update_dir}
fi

# 创建 文件夹
for loop in ${log_array}
do
	# 文件绝对路径
	# ${loop#${relative_url}*} 截取掉relative_url 后的路径
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
  rm -rf ${update_dir}
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

# checkout all of the online version
#online_version_dir="online_version_"$(date "+%Y_%m_%d_%H_%M")
#svn checkout -q ${online_version} ${online_version_dir}/  --username ${username} --password ${password}

# 只检出有变更的一级文件夹
online_version_dir="online_version_"$(date "+%Y_%m_%d_%H_%M")
mkdir ${online_version_dir}
for loop in ${log_array}
do
    work_path=${loop#${relative_url}/*}
    work_path=${work_path%%/*}
    if ! [ -d ${online_version_dir}/${work_path} ]; then
        svn checkout -q ${online_version}/${work_path} ${online_version_dir}/${work_path}  --username ${username} --password ${password}
    fi
done

if ! [ -x "$(command -v git)" ]; then
  cp -rf ${update_dir}/* ${online_version_dir}
  echo 'Error: git is not installed.' >&2
  exit 1
fi

echo -e "online_version have checked out,try to init a git repository...... \n"
# create an empty git repository
cd ${online_version_dir}

echo "/.idea" >> .gitignore

git init
echo -e "\n"
# first commit  add the whole online_version
git add .
git commit -m 'init repository' -q
echo -e "Git initialization is complete, try adding the change file. The repository directory is: ${online_version_dir}\n\n"

cd ../
cp -rf ${update_dir}/* ${online_version_dir}
cd ${online_version_dir}
git add .

echo "please check the diff with your local and the online version, and do the edit you need"


# I'm so sorry,my script has throw a exception

