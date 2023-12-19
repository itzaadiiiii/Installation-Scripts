#!/bin/bash

#VARIABLES :-
SERVICE="apache2"
PACKAGE1="apache2 wget"
PACKAGE2="unzip"
#URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
#ART_NAME="2137_barista_cafe"
TEMPDIR="/tmp/webfiles"

#INSTALLING PACKAGES :-
echo "Installing Packages :-"
sudo apt-get update
sudo apt-get install $PACKAGE1 -y
sudo apt-get update
sudo apt install $PACKAGE2


echo "Starting httpd Service :-"
systemctl start $SERVICE
systemctl enable $SERVICE

echo "creating  a directory to download tooplate website zip file:-"
mkdir -p $TEMPDIR

cd $TEMPDIR

wget $1

unzip $2.zip

echo "copying to another folder:-"
sudo cp -r $2/* /var/www/html

echo "Bounce service:-"
systemctl restart $SERVICE

echo "clean Up of the unnecessary file that is ZIP file, which we downloaded to free up space:-"
rm -rf $TEMPDIR

echo "Checking html file :-"
cat /var/www/html/

echo "Checking status of Httpd :-"
systemctl status $SERVICE

echo "End of the Script.......!!"



# Here we going to pass the arguments to the variables, here we only made changes to the 28,30, and 33 line.
#You can provide arguments as follows:-(script name followed by URL and ART_NAME)
#./websetup_with_cmd_args.sh https://www.tooplate.com/zip-templates/2137_barista_cafe.zip 2137_barista_cafe
