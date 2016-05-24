#!/bin/bash

# This script designed for make a report from bacula database

TMPFILE=`tempfile`
OUT="out.csv"
CMD="bash cmd"
$CMD | grep "Job" | cut -d "." -f1 | sort -u | grep -v "Job" | grep -v "PurgedFiles" | grep -v "Restore" | sed 's/^[ \t]*//' > $TMPFILE
#cat $TMPFILE
echo "Job;Size (GB)" > $OUT
for lines in `cat $TMPFILE`; do
  SUM=0
  RES=`$CMD | grep "Job" | grep $lines | awk '{ print $3 }'`
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
#  echo $RES
done
