su - postgres -c "psql bacula -c \"SELECT Job,JobBytes,JobStatus,PurgedFiles FROM Job WHERE JobBytes <> 0 AND JobStatus = 'T' AND PurgedFiles = 0;\""
