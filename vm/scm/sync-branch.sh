#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

branchType=${BRANCH:0:4}
if [ "$branchType" == "feat" ] || [ "$branchType" == "dvbg" ] || [ "$branchType" == "esbg" ]
then
    parentBranch='main'
fi

if [[ "$branchType" == "qabg" ]]
then
    parentBranch='release/next'
fi

if [[ "$branchType" == "hfbg" ]]
then
    parentBranch='hotfix/next'
fi

if [[ "$parentBranch" == "" ]]
then
    echo "$(tput setaf 1) Your branch prefix is not valid, Please contact to administrator!"
    exit
fi


if [[ "$BRANCH" != "$parentBranch" ]]
then
    git checkout $parentBranch
    git pull origin $parentBranch
    git checkout $BRANCH
    git pull origin $BRANCH
fi

parentBranchCommitId=$(git log origin/$parentBranch --pretty=format:"%h" -1)

isExist=$(git branch --contains $parentBranchCommitId | grep $BRANCH)

if [[ "$isExist" == "" ]]
then
    git merge $parentBranch
    echo "$(tput setaf 2) **************** Merge is initiated *************************"
else
    echo "$(tput setaf 2) 
        *************** Your branch does not require merge.   ****************************"
fi