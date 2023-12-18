#!/bin/bash
echo "Installing Packages :-"
sudo apt-get update
sudo apt-get install apache2 -y
sudo apt-get update
sudo apt-get install wget -y
sudo apt install unzip


echo "Starting httpd Service :-"
systemctl start apache2
systemctl enable apache2

echo "creating  a directory to download tooplate website zip file:-"
mkdir -p /temp/webfiles

cd /temp/webfiles

wget https://www.tooplate.com/zip-templates/2137_barista_cafe.zip

unzip 2137_barista_cafe.zip

echo "copying to another folder :-"
sudo cp -r 2137_barista_cafe/* /var/www/html

echo "Bounce service :-"
systemctl restart apache2

echo "clean Up of the uneccesary file that is ZIP file,which we downloaded to free up space :-"
rm -rf /temp/webfiles

echo "Checking html file :-"
cat /var/www/html/

echo "Checking status of Httpd :-"
systemctl status apache2

echo "End of the Script.......!!"
