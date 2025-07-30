#!/bin/bash

set -e  # Exit on any error

echo "===== Updating system packages ====="
sudo apt update -y

echo "===== Installing required dependencies: Maven, Git, Tree ====="
sudo apt install -y maven git tree

echo "===== Checking Maven version ====="
mvn -version

echo "===== Installing Java (OpenJDK 21 Headless) ====="
sudo apt install -y openjdk-21-jre-headless

echo "===== Checking Java version ====="
java -version

echo "===== Adding Jenkins repository key ====="
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "===== Adding Jenkins repository to APT sources ====="
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "===== Updating package list ====="
sudo apt update -y

echo "===== Installing Jenkins ====="
sudo apt install -y jenkins

echo "===== Enabling and starting Jenkins service ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Checking Jenkins service status ====="
sudo systemctl status jenkins --no-pager

echo "===== Checking Jenkins version ====="
if command -v jenkins >/dev/null 2>&1; then
    jenkins --version
else
    echo "❌ 'jenkins' CLI not found in PATH"
fi
