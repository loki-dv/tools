#!/bin/bash

# Usage: volumes.sh JOBNAME COUNT

if [ -e /var/cache/flant/project ]; then
        PROJECT=`cat /var/cache/flant/project`
fi

case "$PROJECT" in
  "city") 
    FNAME="cityMP-"
  ;;
  *)
    echo "Can't detect project name! Check /var/cache/flant/project file or check script updates!"
    exit 1
  ;;

mysql -u root -pgfhjkm bacula -e "SELECT Job.JobId AS JobId, Job.Name AS JobName,  Client.Name AS Client, Job.Starttime AS JobStart, Job.Type AS JobType, Job.Level AS BackupLevel, Job.Jobfiles AS FileCount, Job.JobBytes AS Bytes, Job.JobStatus AS Status, Job.PurgedFiles AS Purged, FileSet.FileSet, Pool.Name AS Pool, (SELECT Media.VolumeName FROM JobMedia JOIN Media ON JobMedia.MediaId=Media.MediaId WHERE JobMedia.JobId=Job.JobId ORDER BY JobMediaId LIMIT 1) AS FirstVolume, (SELECT count(DISTINCT MediaId) FROM JobMedia WHERE JobMedia.JobId=Job.JobId) AS Volumes FROM Job JOIN Client ON (Client.ClientId=Job.ClientId) AND Job.PurgedFiles = 0 LEFT OUTER JOIN FileSet ON (FileSet.FileSetId=Job.FileSetId)  LEFT OUTER JOIN Pool ON Job.PoolId = Pool.PoolId  ORDER BY Job.JobId DESC" | grep $1.Job | tail -n $2 | awk {'print $14'} | grep -v NULL | tr -s '\r\n' ' ' | sed -e 's/\ /\,/g' | sed -e '"$FNAME"'
