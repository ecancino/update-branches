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

REPO_PATH=$1
UPSTREAM_BRANCH=${2:-"develop"}
SKIP_BRANCHES=("develop", "master")

if [  $# -eq 0 ]; then 
    display_usage
    exit 1
fi 

em "Entering " $REPO_PATH
cd $REPO_PATH;
st "$?"

if [ $? -eq 0 ]; then 
    em "Update " $UPSTREAM_BRANCH
    git checkout "$UPSTREAM_BRANCH" --quiet;
    git pull --rebase origin "$UPSTREAM_BRANCH"  --quiet;
    st "$?"

    for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
        # if [ "$branch" != "develop" ] && [ "$branch" != "master" ]
        if [[ ! "${SKIP_BRANCHES[@]}" =~ "${branch}" ]];
        then
            # printf "Updating ${Yellow}$branch${Reset}\n"
            em "Updating " $branch "\n"
            read -p "Are you sure you want to update? " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                printf "\t⏱: Cheking out";
                git checkout "$branch" --quiet;
                st "$?";

                em "\t⏱: Rebase from " $UPSTREAM_BRANCH
                git rebase "$UPSTREAM_BRANCH" --quiet;
                st "$?";

                git ls-remote --exit-code --quiet --heads origin "$branch" > /dev/null;
                if [ $? -eq 0 ]; then    
                    printf "\t⏱: Update remote ";
                    git push --force-with-lease --quiet;
                    st "$?";
                fi
            fi
        fi
    done

    echo " "

    git checkout "$UPSTREAM_BRANCH" --quiet;

    printf "${Green}DONE${Reset}!\n"; 
fi