#!/bin/bash

read -p "please enter the name of the folder you want to export: " folder

if ! [ -d ${folder} ];then
	echo "The folder is not exists"
fi

export_name=${folder/online_version_/update}

cd ${folder}
echo -e "\n"

# todo 判断是否是git仓库
git add .
git commit -m ' '

echo -e "start export the latest version...... \n"
# archive
git archive -o ../${export_name}.zip HEAD $(git diff --name-only HEAD^)


