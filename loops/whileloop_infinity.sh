!#/bin/bash

counter=2
while true
do
  echo "The counter number is $counter ."
  counter=$(($counter*2))
  sleep 2
done


#so here the output will be
# 2, 4,8,16,32,62,128,256 and on and on till infinity.
