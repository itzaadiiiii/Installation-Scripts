#This script can be used to check whether any given process is running or not, And if not running we make sure its running and up
#!/bin/bash
date
ls /var/run/httpd/httpd.pid

if [$? -eq 0]
#or you can use -f
#[-f /var/run/httpd/httpd.pid]
#above line -f checks whether whether above file is present or not ,if not it returns non zero exit code

then 
  echo "Httpd Process is Running."
else
  echo "Process is not Runing."
  echo "so lets Start the process"
  systemctl start httpd
  if [$? -eq 0]
  then
     echo "httpd Process Started."
  else
     echo "Httpd Process failed to start,please contact admin"
  fi
fi
