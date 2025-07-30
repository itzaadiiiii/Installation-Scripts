#!/bin/bash

set -e  # Exit on any error

echo "===== Updating system packages ====="
sudo apt update

echo "===== Installing required dependencies: Maven, Git, Tree ====="
sudo apt install -y maven git tree

echo "===== Checking Maven version ====="
mvn -version

echo "===== Installing Java (OpenJDK 17) ====="
sudo apt install -y fontconfig openjdk-17-jre

echo "===== Checking Java version ====="
java -version

echo "===== Adding Jenkins repository key ====="
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "===== Adding Jenkins repository to APT sources ====="
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "===== Updating package list ====="
sudo apt update

echo "===== Installing Jenkins ====="
sudo apt install -y jenkins

echo "===== Enabling and starting Jenkins service ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Checking Jenkins service status ====="
sudo systemctl status jenkins --no-pager

echo "===== Checking Jenkins version ====="
jenkins_version=$(sudo jenkins --version || echo "❌ 'jenkins' CLI not in PATH")
echo "Jenkins version: $jenkins_version"
