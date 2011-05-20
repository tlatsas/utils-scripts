#!/bin/bash

# htdocs backup script
#
# run from cron to backup (copy-tar-compress) your website-webapps
#  - you can enable email reporting of the process
#
# author: Tasos Latsas <tlatsas@users.sf.net>


# Only root can run me ;/
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi


# Mail configuration
USE_MAIL="NO"
MAILCLIENT=`which mail`
# !!! Leave quotes as is in subject and CC variables !!!
SUBJECT='"htdocs backup script report"'
CC='" "'
TO="root"


# Folder containing your web content
HTDOCS="/var/www"

# Date format used to name backup folders
#   default: 2010_09_14_104209
DATETIME=`date +%Y_%m_%d_%H%M%S`


# Where to backup date-based backup folders
BACKUP_MAIN="/mnt/backup"

# Use tar and md5sum
TAR=`which tar`
MD5SUM=`which md5sum`

# Tar arguments
#   c - create
#   p - preserve-permissions
#   f - use file as stdout
#   h - follow symlinks
#
#   j - use bzip2 for compression
#   J - use xz (lzma) for compression
#   z - use gunzip for compression
#
TAR_ARGS="-cjphf"

# Output file extension
EXT=".tar.bz2"

# Space sepatated filenames
#   (exclude theese from backup)
#   e.g.: EXCLUDE="site1 site2 site3"
EXCLUDE_LIST="site1 site2 site3"

# Maximum number of backup folders kept.
MAX_BACKUPS=15

#------------------------------------------------------------------------------
# configuration section end - script body
#------------------------------------------------------------------------------

# Get web content list
cd ${HTDOCS}
WCONTENT=`ls ${HTDOCS}`

# Create backup dir varible
BACKUP_DIR="${BACKUP_MAIN}/${DATETIME}"

# Create backup folder and give permissions
if [ ! -d ${BACKUP_DIR} ]; then
  mkdir -p ${BACKUP_DIR}
  chown root:root ${BACKUP_DIR}
  chmod 0600 ${BACKUP_DIR}
fi

# Main backup process
for WDIR in ${WCONTENT}
do
  SKIP=0

  # Check if folder has to be excluded
  if [ -n "${EXCLUDE_LIST}" ]; then
    for EXCLUDE_DIR in ${EXCLUDE_LIST}
    do
      [ "${WDIR}" == "${EXCLUDE_DIR}" ] && SKIP=1
    done
  fi

  # Tar and compress the site folder
  if [[ ${SKIP} -eq 0 ]]; then
    ${TAR} ${TAR_ARGS} ${BACKUP_DIR}"/"${WDIR}${EXT} ${WDIR}
  fi
done

# Generate info file
cd ${BACKUP_DIR}

echo ":: Backup process finished at ${DATE} ::"       > backup.info
echo "   files in ${BACKUP_DIR} :"                   >> backup.info
echo "---------------------------------------------" >> backup.info
ls -lh *${EXT}                                       >> backup.info
echo                                                 >> backup.info
echo ":: MD5 Check sums"                             >> backup.info
echo "---------------------------------------------" >> backup.info
${MD5SUM} *${EXT}                                    >> backup.info

# If email is enabled mail the report
#
if [ ${USE_MAIL} == "YES" ]; then
  ${MAILCLIENT} -s ${SUBJECT} -c ${CC} ${TO} < backup.info
fi

#  Cleanup some old backups based on $MAX_BACKUPS
#
cd ${BACKUP_MAIN}
if [ `ls | wc -l` -gt ${MAX_BACKUPS} ]; then
  OLDEST=`ls | sort -r | head -n 1`
  rm -r ${OLDEST}
fi

exit 0

# vim: ts=2 sw=2 et:
