#!/bin/sh

git fetch >/dev/null 2>&1
BRANCH=''
if [ $# -eq 0 ]; then
    BRANCH=$(git branch -a | grep -v -E '^\*' | sed -E 's/( *|->.*)//' | peco | awk 'NR==1')
else
    if [ $1 = 'master' ] || [ $1 = 'develop' ]; then
	BRANCH=$1
    else
	BRANCH=$(git branch -a | grep "$1" | awk 'NR==1' | sed -E 's/\*? *//')
        if [ -z "$BRANCH" ] ; then BRANCH=$1; fi
    fi
fi
if [ -n "$BRANCH" ] ; then
    if echo $BRANCH | grep -q 'origin'; then
	TRIMMED_BRANCH=$(echo $BRANCH | sed -E 's/(remotes\/|origin\/)//g')
	if git branch -a | grep -q $TRIMMED_BRANCH; then
	    git switch $TRIMMED_BRANCH
	else
	    echo "there is not such a branch."
	fi
    else
	if git branch | grep -q $BRANCH; then
	    git switch $BRANCH
	else
	    echo "there is not such a branch."
	fi
    fi
fi
