#!/bin/bash

set -e  # Exit on any error

echo "===== Detecting OS ====="
OS=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi
echo "✅ Detected OS: $OS"

echo "===== Updating system packages ====="
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo apt update -y
    sudo apt install -y maven git tree openjdk-21-jre-headless wget curl gnupg
elif [[ "$OS" == "amzn" || "$OS" == "centos" || "$OS" == "rhel" ]]; then
    sudo yum update -y
    sudo yum install -y maven git tree java-21-openjdk wget curl
else
    echo "❌ Unsupported OS"
    exit 1
fi

echo "===== Validating Maven version ====="
mvn_version=$(mvn -version | head -n 1)
echo "✅ Maven Installed: $mvn_version"

echo "===== Validating Java version ====="
java_version=$(java -version 2>&1 | head -n 1)
echo "✅ Java Installed: $java_version"

echo "===== Installing Jenkins ====="
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
      sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y
    sudo apt install -y jenkins
elif [[ "$OS" == "amzn" || "$OS" == "centos" || "$OS" == "rhel" ]]; then
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins
else
    echo "❌ Unsupported OS for Jenkins setup"
    exit 1
fi

echo "===== Enabling and starting Jenkins service ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Checking Jenkins status ====="
sudo systemctl status jenkins --no-pager || echo "⚠️ Jenkins service failed to start"

echo "===== Jenkins version ====="
if command -v jenkins >/dev/null 2>&1; then
    jenkins_version=$(jenkins --version)
    echo "✅ Jenkins Installed: Version $jenkins_version"
else
    echo "❌ Jenkins CLI not found in PATH"
fi

echo "===== Fetching Initial Jenkins Admin Password ====="
initial_pass_file="/var/lib/jenkins/secrets/initialAdminPassword"
if [ -f "$initial_pass_file" ]; then
    initial_pass=$(sudo cat "$initial_pass_file")
    echo "🔑 Jenkins Initial Admin Password: $initial_pass"
else
    echo "❌ Cannot find Jenkins initial admin password at $initial_pass_file"
fi
