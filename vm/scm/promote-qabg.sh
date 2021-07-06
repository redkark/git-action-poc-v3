#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

branchType=${BRANCH:0:4}
if [[ "$branchType" == "qabg" ]]
then
    parentBranch='release/next'
else 
    echo "$(tput setaf 1) ***** This script is applicable only for qabg branches! **** "
    exit;
fi

git pull origin $BRANCH
git checkout main
git pull origin main
# git checkout $parentBranch
# git pull origin $parentBranch
git checkout $BRANCH

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
    newBranchName="${BRANCH/qabg/qarn}"
    git checkout -b $newBranchName
    git reset --hard $lastCommitId
    git push origin $newBranchName
    gh pr create -t "Merge qarn branch for $BRANCH to release/next branch" -b "PR merging" -B "$parentBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
else
    # create PR on that branch and merge into release/next branch
    gh pr create -t "Merge qarn branch for $BRANCH to release/next branch" -b "PR merging" -B "$parentBranch"
    echo "$(tput setaf 2)****************** PR is created successfully, Please assign reviewer to this PR *******************  "
fi