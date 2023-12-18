#!/bin/bash

#VARIABLES :-
SERVICE="apache2"
PACKAGE1="apache2 wget"
PACKAGE2="unzip"
URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
ART_NAME="2137_barista_cafe"
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

wget $URL

unzip $ART_NAME.zip

echo "copying to another folder :-"
sudo cp -r $ART_NAME/* /var/www/html

echo "Bounce service :-"
systemctl restart $SERVICE

echo "clean Up of the uneccesary file that is ZIP file,which we downloaded to free up space :-"
rm -rf $TEMPDIR

echo "Checking html file :-"
cat /var/www/html/

echo "Checking status of Httpd :-"
systemctl status $SERVICE

echo "End of the Script.......!!"
