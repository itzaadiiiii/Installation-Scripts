#!/bin/bash

sudo systemctl stop httpd
sudo rm -rf /var/www/html/*
sudo yum remove httpd wget unzip



# If ubuntu then use apache2 instead of httpd 
