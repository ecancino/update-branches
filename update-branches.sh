#!/usr/bin/env bash

source "$(dirname -- ${0})/status.sh";

bold() {
    printf "$1${BWhite}$2${Reset}$3"
}

em() {
    printf "$1${Yellow}$2${Reset}$3"
}

display_usage() { 
    em "" "USAGE: \n" 
    bold "" "update_branches " "repository_path [upstream_branch]\n"
    bold "  " "repository_path"   "   Specify the repository folder to update\n"
    bold "  " "upstream_branch"   "   Specify the branch to update from\n"
    exit 1
} 

pull_branch() {
    printf "\t⏱: Rebase from ${1}"
    git checkout "$1" --quiet;
    git pull --rebase origin "$1"  --quiet;
    st "$?"
}

push_branch() {
    git ls-remote --exit-code --quiet --heads origin "$1" > /dev/null;
    if [ $? -eq 0 ]; then    
        printf "\t⏱: Update remote ";
        git push --force-with-lease --quiet;
        st "$?";
    fi
}

if [ $# -eq 0 ]; then 
    display_usage
    exit 1
fi 

REPO_PATH=$1
UPSTREAM_BRANCH=${2:-"develop"}
SKIP_BRANCHES=("develop", "master")

em "Entering " $REPO_PATH
cd $REPO_PATH;
st "$?"

pull_branch $UPSTREAM_BRANCH

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    if [[ ! "${SKIP_BRANCHES[@]}" =~ "${branch}" ]];
    then
        pull_branch $branch;
        push_branch $branch;
    fi
done

echo " "
git checkout "$UPSTREAM_BRANCH" --quiet;
printf "${Green}DONE${Reset}!\n"; 

