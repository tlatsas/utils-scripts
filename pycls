#!/bin/sh
#
# Author: Tasos Latsas
#
# Clears python compiled files (pyc and pyo files)
#

show_help () {
cat << EOF
usage: $0 options

This script removes pyc and pyo files from the given path.


Default path is the current working directory
By default it searches all subfolders recursively

OPTIONS:
   -h          Show this message
   -p path     Path to search for files
   -d levels   Max depth of subfolders to search 
   -v          Verbose
EOF
}

_find=`which find`
_path=""
_depth=""
_verbose=""

while getopts ":hvp:d:" options; do
  case $options in
    h)
      show_help
      exit 0
      ;;
    v)
      _verbose="-print"
      ;;
    p)
      _path=${OPTARG}
      ;;
    d)
      _depth="-maxdepth ${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

$_find $_path $_depth \( -name '*.pyc' -o -name '*.pyo' \) $_verbose -delete

exit 0
