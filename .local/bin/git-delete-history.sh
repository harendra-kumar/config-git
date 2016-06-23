#!/bin/bash
set -o errexit

# Based on a script by David Underhill
# Script to permanently delete files/folders from your git repository.  To use
# it, cd to your repository's root and then run the script with a list of paths
# you want to delete, e.g., git-delete-history path1 path2

function usage () {
  echo "Usage: $(basename $0) -f <path1> <path2> ..."
  echo
  echo "Delete a file in git repository along with all of its hostory."
  echo "For safety -f is required."
  exit
}

# $1: message
function die () {
  >&2 echo $1
  exit 1
}

while test -n "$1"
do
  case $1 in
    -f) FORCE=true; shift;;
    --*|-*) usage;;
    *) break;;
  esac
done

test -n "$FORCE" || usage
test -n "$1" || usage

# make sure we're at the root of git repo
if [ ! -d .git ]; then
    echo "Error: must run this script from the root of a git repository"
    exit 1
fi

# remove all paths passed as arguments from the history of the repo
files=$@
git filter-branch \
  --index-filter "git rm -rf --cached --ignore-unmatch $files" HEAD || exit 1

# remove the temporary history git-filter-branch otherwise leaves behind for a
# long time
rm -rf .git/refs/original/ && \
  git reflog expire --all &&  \
  git gc --aggressive --prune
