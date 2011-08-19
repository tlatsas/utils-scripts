#!/bin/bash

# Simple script to create an initial
# post suitable for use with jekyll

if [[ -z $1 ]]; then
    echo "A post title is required. Bye.."
    exit 1
fi

_post=$(echo $1 | tr ' ' '-')
_date=$(date +'%Y-%m-%d')
_datetime=$(date +'%Y-%m-%d %H:%M:%S')
_title="${_date}-${_post}.markdown"
_cwd=$(pwd)
_post_file="${_cwd}/${_title}"

if [[ -f ${_post_file} ]]; then
    echo "File already exists. Bye.."
    exit 1
fi

cat << EOF >| ${_post_file}
---
layout: post
title: $1
date: $_datetime
---
EOF

exit 0
