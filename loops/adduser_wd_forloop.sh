!#/bin/bash
MYUSER="ALPHA BETA GAMMA"
for usr in $MYUSER
do
  echo "Adding USER $usr "
  adduser $usr
  id $usr
  echo "User $usr Added Successfully....."
done
