#!/bin/bash

set -e

echo "===== Detecting OS ====="
OS=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi
echo "✅ Detected OS: $OS"

echo "===== Stopping Jenkins service ====="
sudo systemctl stop jenkins || true
sudo systemctl disable jenkins || true

echo "===== Removing Jenkins, Java, Maven ====="
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo apt remove --purge -y jenkins openjdk-21-jre-headless maven git tree wget curl gnupg
    sudo apt autoremove -y
    sudo apt clean
elif [[ "$OS" == "amzn" || "$OS" == "centos" || "$OS" == "rhel" ]]; then
    sudo yum remove -y jenkins java-21-openjdk maven git tree wget curl
    sudo yum autoremove -y || true
    sudo yum clean all
else
    echo "❌ Unsupported OS"
    exit 1
fi

echo "===== Removing Jenkins repository and keys ====="
sudo rm -f /etc/apt/sources.list.d/jenkins.list /usr/share/keyrings/jenkins-keyring.asc
sudo rm -f /etc/yum.repos.d/jenkins.repo

echo "===== Removing Jenkins data directory ====="
sudo rm -rf /var/lib/jenkins /etc/jenkins /var/log/jenkins

echo "===== Final cleanup complete ====="
echo "🧹 Jenkins, Java, Maven and related tools have been uninstalled successfully."
