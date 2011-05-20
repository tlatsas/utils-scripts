#!/bin/sh
#
# MySql Database backup script
#
# use mysqldump to backup databases
#
# Tasos Latsas <tlatsas@users.sf.net>
#

# Go away! only root can run me ;/
if [ ${EUID} -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Date format used to name backup folders
# the following produces: year_month_day_time
#   eg: 2010_09_14_104209
DATETIME=`date +%Y_%m_%d_%H%M%S`

# Where to put date-based backup folders
BACKUP_MAIN="/mnt/backup/mysql"

# MySQL Specific configuration
MYSQL=`which mysql` || exit 1
DUMP=`which mysqldump` || exit 1
HOST="localhost"
USER="root"
PASS="<sql-root-pass-here>"
DEFAULT_CHARSET="utf8"

# Space sepatated databases - exclude theese from back-up
#   e.g. : EXCLUDE="testdb exclude_db exclude_me_too_db"
EXCLUDE="db1 db2 db3"

# Maximum number of backup folders kept.
MAX_BACKUPS=30

# Use md5sum for report
MD5SUM=`which md5sum` || exit 1

# Compress with gunzip
GZIP=`which gzip` || exit 1
ARGS="-9"
EXT=".gz"

# Mail configuration
USEMAIL="NO" # change to "YES" to enable email report
if [ ${USEMAIL} == "YES" ]; then
  MAILCLIENT=`which mail` || exit 1
  # Leave quotes as is in subject and CC variables
  SUBJECT='"mysql backup script"'
  CC='" "'
  TO="root"
fi

#
#===[ begin backup phase ]===========================================
#

# Create backup dir
BACKUP_DIR="${BACKUP_MAIN}/${DATETIME}"

# Create backup folder and give permissions
if [ ! -d ${BACKUP_DIR} ]; then
  mkdir -p ${BACKUP_DIR}
  chown root:root ${BACKUP_DIR}
  chmod 0600 ${BACKUP_DIR}
fi

cd ${BACKUP_DIR}

# Connect to mysql and get the database list
DBS="$($MYSQL -u $USER -h $HOST -p$PASS -Bse 'show databases')"

# The actual backup loop
for _DB in $DBS
do
  SKIP=0

  # Check if db has to be excluded
  if [ -n "${EXCLUDE}" ]; then
    for EX_DB in ${EXCLUDE}
    do
      [ "${_DB}" == "${EX_DB}" ] && SKIP=1
    done
  fi

  # Dump mysql db and compress
  if [ ${SKIP} -eq 0 ]; then
    FILE="${BACKUP_DIR}/${_DB}${EXT}"
    $DUMP --default-character-set=${DEFAULT_CHARSET} -u ${USER} -h ${HOST} -p${PASS} ${_DB} | ${GZIP} ${ARGS} > ${FILE}
  fi
done

# Generate report file
cd ${BACKUP_DIR}
echo "Backup files generated at "${DATETIME} > backup.info
echo "------------------------------------" >> backup.info
ls -lh *${EXT}                              >> backup.info
echo                                        >> backup.info

echo "MD5 Check sums"                     >> backup.info
echo "----------------------------------" >> backup.info
md5sum *${EXT}                            >> backup.info

# If e-mail is enabled mail the report
if [ ${USEMAIL} == "YES" ]; then
  ${MAILCLIENT} -s ${SUBJECT} -c ${CC} ${TO} < backup.info
fi

# Cleanup some old backups based on $MAX_BACKUPS
cd ${BACKUP_MAIN}
if [ `ls | wc -l` -gt ${MAX_BACKUPS} ]; then
  OLDEST=`ls | sort | head -n 1`
  rm -r ${OLDEST}
fi

exit 0

# vim: ts=2 sw=2 et:
