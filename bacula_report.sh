#!/bin/bash

# This script designed for make a report from bacula database

TMPFILE=`tempfile`
COMMAND="mysql --defaults-extra-file=/etc/mysql/debian.cnf -e"
MYSQL_COMMAND="USE bacula; SELECT Job,JobBytes,JobStatus,PurgedFiles FROM Job WHERE JobBytes <> 0 AND JobStatus = 'T' AND PurgedFiles = 0;"
OUT="out.csv"
#$COMMAND $MYSQL_COMMAND | grep "Job" | cut -d "." -f1 | sort -u > $TMPFILE
$COMMAND "USE bacula; SELECT Job,JobBytes,JobStatus,PurgedFiles FROM Job WHERE JobBytes <> 0 AND JobStatus = 'T' AND PurgedFiles = 0;" | grep "Job" | cut -d "." -f1 | sort -u | grep -v "Job" | grep -v "PurgedFiles" | grep -v "Restore" > $TMPFILE

echo "Job;Size (GB)" > $OUT
for lines in `cat $TMPFILE`; do
  SUM=0
#  RES=`$COMMAND $MYSQL_COMMAND | grep "Job" | grep $lines | awk '{ print $2 }'`
  RES=`$COMMAND "USE bacula; SELECT Job,JobBytes,JobStatus,PurgedFiles FROM Job WHERE JobBytes <> 0 AND JobStatus = 'T' AND PurgedFiles = 0;" | grep "Job" | grep $lines | awk '{ print $2 }'`
  for blines in `echo $RES`; do
    let SUM=$SUM+$blines
  done
  SIZE=`echo $(echo "scale=4; ($SUM/1024/1024/1024)" | bc)`
#  echo "DBG1: $SIZE"
  if [ `echo $SIZE | cut -b 1` == "." ]; then
    SIZE="0$SIZE"
  fi
#    echo "DBG2: $SIZE"
  SIZE=`echo $SIZE | sed -e 's/\./,/g'`
#    echo "DBG3: $SIZE"
  echo "$lines;$SIZE" >> $OUT
done

