#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

branchType=${BRANCH:0:4}
if [[ "$branchType" == "hfbg" ]]
then
    parentBranch='hotfix/next'
else 
    echo "$(tput setaf 1) ***** This script is applicable only for hfbg branches! **** "
    exit;
fi

git pull origin $BRANCH

commitMsg=$(git log $BRANCH --oneline --pretty="%s" -1)

searchWord="Merge branch 'main' into $BRANCH"

firstCommit=$(git log $BRANCH --oneline --pretty="%h" -n 1)

isBranchRequired=0

if [[ "$commitMsg" =~ .*"$searchWord".* ]]; then
  showMsg=$(git show --format=short $firstCommit)
    i=1
    while IFS= read -r line
    do
        if [ "$i" -eq "2" ]; then
            if [[ "$line" =~ .*"Merge:".* ]]; then
                isBranchRequired=1
                break
            fi
        fi
        i=$((i + 1))
    done <<< "$showMsg"
fi

if [[ "$isBranchRequired" -eq "1" ]]
then
    lastCommitId=$(git log $BRANCH --oneline --pretty="%h" --skip 1 -n 1)    
    newHfBranchName="${BRANCH/hfbg/hfhn}"
    git checkout -b $newHfBranchName
    git reset --hard $lastCommitId
    git push origin $newHfBranchName
    echo "$(tput setaf 3)"
    gh pr create -t "Merge hfhn branch for $BRANCH to hotfix/next branch" -b "Hotfix PR merge to hotfix/next branch" -B "$parentBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
    echo "$(tput setaf 7)"

    git checkout $BRANCH
    releaseBranch='release/next'
    newRnBranchName="${BRANCH/hfbg/hfrn}"
    git checkout -b $newRnBranchName
    git reset --hard $lastCommitId
    git push origin $newRnBranchName
    echo "$(tput setaf 3)"
    gh pr create -t "Merge hfrn branch for $BRANCH to release/next branch" -b "Hotfix PR merge to release/next branch" -B "$releaseBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
else
    # create PR on that branch and merge into release/next branch
    newHfBranchName="${BRANCH/hfbg/hfhn}"
    git checkout -b $newHfBranchName
    git push origin $newHfBranchName
    echo "$(tput setaf 3)"
    gh pr create -t "Merge hfhn branch for $BRANCH to hotfix/next branch" -b "Hotfix PR merge to hotfix/next branch" -B "$parentBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
    echo "$(tput setaf 7)"

    git checkout $BRANCH
    releaseBranch='release/next'
    newRnBranchName="${BRANCH/hfbg/hfrn}"
    git checkout -b $newRnBranchName
    git push origin $newRnBranchName
    echo "$(tput setaf 3)"
    gh pr create -t "Merge hfrn branch for $BRANCH to release/next branch" -b "Hotfix PR merge to release/next branch" -B "$releaseBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
fi

# newHfBranchName="${BRANCH/hfbg/hfhn}"
# git checkout -b $newHfBranchName
# git push origin $newHfBranchName
# gh pr create -t "Merge hfhn branch for $BRANCH to hotfix/next branch" -b "Hotfix PR merge to hotfix/next branch" -B "$parentBranch"
# echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "

