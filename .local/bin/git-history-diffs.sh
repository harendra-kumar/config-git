#!/bin/bash

# Generate an email format patch with all the historical commits of a
# file or dir. The patch can be applied with git am < patch

# $1: message
function die () {
  >&2 echo $1
  exit 1
}

test -n "$@" || die "Usage: $0 <files or dirs>"

git log --pretty=email --patch-with-stat --reverse --full-index --binary -- $@
