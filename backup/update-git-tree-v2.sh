#!/bin/bash
###
# @Author: Nathaniel
# @Date: 2021-02-14 17:05:46
# 当然find还有很多实用的参数,我们可以更加细化的配置,
# 比如聚目录查找层级: maxdepth(最大)  , mindepth(最小) 
# find . -maxdepth 3 -type d -name .git  -exec sh -c "cd \"{}\"/../ && pwd && git pull --rebase" \;
### 

LOG_FILE=$(pwd)/update-git.log
IGNORE_DIR=("clearmaster" "Auto.js" "Hardcoder" "AppService" "RxMVP")

echo "`date '+%Y%m%d-%H:%M:%S'` --> update $(pwd) now" > $LOG_FILE
# 1. i=`expr $i + 1`;
# 2. let i+=1;
# 3. ((i++));
# 4. i=$[$i+1];
# 5. i=$(( $i + 1 ))
withinArray(){
    count=1
    # echo ${IGNORE_DIR[*]}
    for ignore in $IGNORE_DIR; do
        if [[ $1 =~ $ignore ]] ; then
            count=$[$count+1];
        fi
    done
    return $count
}

# 将echo做为返回值
convertNum(){
    if [[ $1 -eq 1 ]] ; then
        echo "true"
    else
        echo "false"
    fi
}

isContainsV1(){
    withinArray $1
    # shell 中的 return 只有 $? 才能拿到,且必须是0-255的值
    hasWithin=$?
    num2string=$(convertNum $hasWithin)
    echo "■ `date '+%Y%m%d-%H:%M:%S'` --> isContainsV1 $1 constains 【${IGNORE_DIR[*]}】 or not $num2string, result number is $hasWithin" >> $LOG_FILE
}

isContainsV2(){
    count=1
    for ignore in $IGNORE_DIR; do
        if [[ $1 =~ $ignore ]] ; then
            ((count++));
        fi
    done
    echo $count
}

## 查找所有git仓库(包含.git的目录)，并且按照字母降序排序(A->Z --> a->z)
for repo in `find $(pwd) -maxdepth 3 -type d -name .git | sort -t '\\0' -n`; do
	repoDir=`cd $repo/../ && pwd | awk '{print $1}'`
    echo "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■" >> $LOG_FILE
    isContainsV1 $repoDir
    hasContains=$(isContainsV2 $repoDir)
    echo "■ `date '+%Y%m%d-%H:%M:%S'` -->isContainsV2 $1 constains 【${IGNORE_DIR[*]}】 or not result number is $hasContains"
    if [[ $hasContains -gt 1 ]] ; then
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir contains ${IGNORE_DIR[*]}, $repoDir will be ignore" >> $LOG_FILE
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir will be ignore update"
        else
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir not contains ${IGNORE_DIR[*]},  $repoDir will be update" >> $LOG_FILE
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir is updating now ......." >> $LOG_FILE
            cd $repoDir
            repoUrl=`cat .git/config | grep 'url = '`
            realUrl=${repoUrl/  url = /}
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> real repository url is $realUrl" >> $LOG_FILE
            branchName=`git branch | grep \* | cut -d ' ' -f2`
            echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir current branch is $branchName" >> $LOG_FILE
            if [[ $(git ls-remote --heads origin $branchName | wc -l | awk '{print $1}') -eq 1 ]]; then
                git fetch --all
                git log --pretty=oneline -1 >> $LOG_FILE
                if [ $(git status --short -uno | wc -l | awk '{print $1}') -eq 0 ]; then
                    echo "■ `date '+%Y%m%d-%H:%M:%S'` --> reset command is git reset --hard origin/$branchName" >> $LOG_FILE
                    git reset --hard origin/$branchName >> $LOG_FILE
                fi
                git pull 2>&1 | tee -a $LOG_FILE
                echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir has been updated" >> $LOG_FILE
            else
                echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir could not access from remote" >> $LOG_FILE
            fi
            cd ..
        fi
    echo "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■" >> $LOG_FILE
    echo "■ `date '+%Y%m%d-%H:%M:%S'` --> $repoDir has been updated"
    echo -e "\n\n\n" >> $LOG_FILE
done

echo "`date '+%Y%m%d-%H:%M:%S'` --> all repositories in $(pwd) are updated" >> $LOG_FILE