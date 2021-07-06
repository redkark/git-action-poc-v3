#!/bin/bash

USERNAME=$(git config user.userid)

if [[ "$USERNAME" == "" ]]
then
    echo "$(tput setaf 1) Your GitHub User Account is not setup."
    read -p "$(tput setaf 2) Please provide your GitHub username which will be used for creating the branches: "  userid
    git config user.userid "$userid"
    echo "Your GitHub Account has been setup successfully. Kindly run the branch-create.sh command once again."
    exit;
fi

branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

echo "$(tput setaf 2) Which type of branch do you want to create? 
1 - Feature Branch
2 - Dev Bug Branch
3 - QA Bug Branch
4 - Hotfixes Bug Branch
5 - ESN Bug Branch"

while :; do
  read -p "Select the type of branch you want to create: " branchOption
  [[ $branchOption =~ ^[0-9]+$ ]] || { echo "Enter a valid number"; continue; }
  if ((branchOption >= 1 && branchOption <= 5)); then
    break
  else
    echo "$(tput setaf 1) ******* Selected number is out of range. Try again!"
  fi
done

read -p "Enter JIRA Ticket Number: "  ticket

while :; do
  read -p "$(tput setaf 2)Enter the branch description: "  description
  if (("${#description}" >= 1 && "${#description}" < 21)); then
    break
  else
    echo "$(tput setaf 1) ********* Branch description should be less than 20 characters!"
  fi
done

description=${description// /-}
ticket=${ticket// /-}
echo "$(tput setaf 3) "

if test "$branchOption" = 1; then
    git checkout main
    git pull origin main
    git checkout -b "feat-"${ticket,,}"/"$USERNAME"/"${description,,}
fi

if test "$branchOption" = 2; then
    git checkout main
    git pull origin main
    git checkout -b "dvbg-"${ticket,,}"/"$USERNAME"/"${description,,}
fi

if test "$branchOption" = 3; then
    git checkout release/next
    git pull origin release/next  
    git checkout main
    git pull origin main      
    git checkout -b "qabg-"${ticket,,}"/"$USERNAME"/"${description,,}
    git reset --hard release/next    
fi

if test "$branchOption" = 4; then
    git checkout main
    git pull origin main    
    git checkout hotfix/next
    git pull origin hotfix/next    
    git checkout -b "hfbg-"${ticket,,}"/"$USERNAME"/"${description,,}
    git reset --hard hotfix/next
fi

if test "$branchOption" = 5; then
    git checkout main
    git pull origin main
    git checkout -b "esbg-"${ticket,,}"/"$USERNAME"/"${description,,}
fi

echo "$(tput setaf 2) ********************** Your Branch is created successfully ****************************"