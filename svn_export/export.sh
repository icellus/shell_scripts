#!/bin/bash

read -p "please enter the name of the folder you want to export: " folder

if test -d ${folder}
then 
	echo "The folder is not exists"
fi

export_name=${folder/online_version_/update}

cd ${folder}

# todo 判断是否是git仓库
git add .
git commit -m ' '

echo "start export the latest version......"
# archive
git archive -o ../${export_name}.zip HEAD $(git diff --name-only HEAD^)


