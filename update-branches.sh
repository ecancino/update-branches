#!/usr/bin/env bash

source "$(dirname -- ${0})/status.sh";

echo "Entering repo"
cd $1;
if [ $? -eq 0 ];
then 
    echo "Fetching..."
    git checkout develop --quiet;
    git fetch --quiet;
    st "$?"

    echo "Retrieving branches..."
    for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
        if [ "$branch" != "develop" ] 
        then
            git ls-remote --exit-code --quiet --heads origin "$branch" > /dev/null;
            if [ $? -eq 0 ]; 
            then    
                printf "Updating ${On_Green}${Yellow}$branch${Reset}\n"

                printf "\t⏱: Cheking out";
                git checkout "$branch" --quiet;
                st "$?";

                printf "\t⏱: Rebase develop";
                git rebase develop --quiet;
                st "$?";

                printf "\t⏱: Update remote ";
                git push --force-with-lease --quiet;
                st "$?";
            fi
        fi
    done

    git checkout develop --quiet;

    printf "${Green}DONE${Reset}!\n"; 
fi