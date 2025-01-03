#!/bin/bash
###
# @Author: Nathaniel
# @Date: 2021-02-14 17:05:46
# 当然find还有很多实用的参数,我们可以更加细化的配置,
# 比如聚目录查找层级: maxdepth(最大)  , mindepth(最小) 
# find . -maxdepth 3 -type d -name .git  -exec sh -c "cd \"{}\"/../ && pwd && git pull --rebase" \;
# https://zhuanlan.zhihu.com/p/181609730
###
ROOT_PATH=$(pwd)
LOG_FILE=$ROOT_PATH/update-git.log
echo "`date '+%Y%m%d-%H:%M:%S'` updated git repos on `uname -a`" > $LOG_FILE

start_time=$(date --date="$(date '+%Y-%m-%d %H:%M:%S')" +%s)
echo "`date '+%Y-%m-%d %H:%M:%S'` ---> update $(pwd) now" 2>&1 | tee -a $LOG_FILE

# 查找所有git仓库(包含.git的目录)，并且按照字母降序排序(A->Z --> a->z)
for repo_git in `find $ROOT_PATH -maxdepth 5 -type d -name .git | sort -t '\\0' -n`; do
	repo_dir=$(cd $repo_git/../ && pwd | awk '{print $1}')
    echo -e "⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️" 2>&1 | tee -a $LOG_FILE
	echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` --> $repo_dir is updating now ......." 2>&1 | tee -a $LOG_FILE
	repo_url=`cat $repo_git/config | grep 'url = '`
	real_url=`echo ${repo_url/  url = /} | awk '{print $3}'`
	echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> $repo_dir remote url is $real_url" 2>&1 | tee -a $LOG_FILE
	[[ $repo_dir =~ "RxMVP" ]] || [[ $repo_dir =~ "viponapp" ]] || [[ $repo_dir =~ "wukong" ]] || [[ $repo_dir =~ "AAnimeExt" ]] && continue
	cd $repo_dir
	branchName=`git branch | grep \* | cut -d ' ' -f2`
	# git ls-remote --heads origin 2>/dev/null | awk -F 'refs/heads/' '{print $2}' | grep -x "main" | wc -l
	# git ls-remote --heads origin $branchName | wc -l | awk '{print $1}
	branch_exists=$(git ls-remote --heads origin 2>/dev/null | awk -F 'refs/heads/' '{print $2}' | grep -x "main" | wc -l)
	branch_updated=$(git log --since='3 days ago' --oneline | wc -l | awk '{print $1}')
	if [[  $branch_exists -eq 1 ]] || [[ $branch_updated -eq 1 ]];then
			git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5 | awk '{print$1}')" | tee -a $LOG_FILE
			echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> $repo_dir has linked remote, branch is $branchName" 2>&1 | tee -a $LOG_FILE
			# find -name test | xargs rm -rf
			git rm -rf .git/refs/original/*
			rm -rf .git/refs/original/*
			git rm -rf .git/logs/*
			rm -rf .git/logs/*
			git reflog expire --expire=now --all
			git fsck --full --unreachable
			git repack -A -d
			git gc --aggressive --prune=now
			echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> recent git log is $(git log --pretty=oneline -1) " 2>&1 | tee -a $LOG_FILE
			result=$(git status --short -uno | wc -l | awk '{print $1}')
			echo -e "⭐️ `date '+%Y%m%d-%H:%M:%S'` ---> $repo_dir branch is $branchName, git status -s is $result" 2>&1 | tee -a $LOG_FILE
			# if [[ $result -eq 0 ]]; then
			echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> reset command is git reset --hard origin/$branchName" 2>&1 | tee -a $LOG_FILE
			git fetch --all 2>&1 | tee -a $LOG_FILE
			# git branch -D $branchName
			# git rebase -i
			git reset --hard origin/$branchName 2>&1 | tee -a $LOG_FILE
			echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> $repo_dir has been updated" 2>&1 | tee -a $LOG_FILE
			# git remote -v
			# git remote remove origin
			# git remote add origin $real_url
			# git push -u origin --all
	else
		echo "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> $repo_dir could not access from remote or none commit within 3 days ago" 2>&1 | tee -a $LOG_FILE
	fi
    curr_pid=$(ps -ef | grep git | grep -v grep | wc -l | awk '{print $2}')
    count_pid=$(ps -ef|grep git | grep -v grep | wc -l)
	echo -e "⭐️ `date '+%Y-%m-%d %H:%M:%S'` ---> git client count is $count_pid" 2>&1 | tee -a $LOG_FILE

	echo -e "⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️" 2>&1 | tee -a $LOG_FILE
	echo -e "\n\n" 2>&1 | tee -a $LOG_FILE
done

echo "`date '+%Y-%m-%d %H:%M:%S'` ---> all repositories in $ROOT_PATH are updated" 2>&1 | tee -a $LOG_FILE

stop_time=$(date --date="$(date '+%Y-%m-%d %H:%M:%S')" +%s)
using_duration=$((stop_time - start_time))
const_time=`expr $stop_time - $start_time`
echo "TIME: $using_duration ($const_time) s"
