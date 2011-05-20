#!/bin/bash

# free unused ram
#   drop the page cache and/or inode and dentry caches
#
# Tasos Latsas

# only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# set the variables
FILE=/proc/sys/vm/drop_caches
LVL=$1

# set the default value if no argument supplied
if [[ -z $1 ]]; then
   LVL=1
fi

case $LVL in
  1|2|3)
      if [[ "${LVL}" == "1" ]]; then
          echo -n "Dropping pagecache..."
      elif [[ "${LVL}" == "2" ]]; then
          echo -n "Dropping dentries and inodes..."
      else
          echo -n "Dropping pagecache, dentries and inodes..."
      fi

      echo ${LVL} > ${FILE}

      if [[ $? -eq "1" ]]; then
          echo "FAILED"
          exit 1
      else
          echo "DONE"
      fi
      ;;

  *)
      echo "Usage: $0 [1|2|3]"
      echo
      echo "   1     drop pagecache"
      echo "   2     drop dentries and inodes"
      echo "   3     drop pagecache, dentries and inodes"
      echo
      echo "   default value = 1"
      echo
      exit 1
      ;;

esac

exit 0
