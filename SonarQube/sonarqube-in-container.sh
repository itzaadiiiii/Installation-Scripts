#!/bin/bash

# Detect OS
OS=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
echo "Detected OS: $OS"

# Step 1: Remove conflicting Docker-related packages (Ubuntu/Debian-based only)
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  echo "Removing any existing Docker-related packages..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove $pkg
  done
fi

# Step 2: Install Docker CE based on the OS
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  echo "Installing Docker on Ubuntu/Debian..."

  sudo apt-get update
  sudo apt-get install ca-certificates curl

  # Add Docker's GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add Docker repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

elif [[ "$OS" == "amzn" || "$OS" == "centos" ]]; then
  echo "Installing Docker on Amazon Linux / CentOS..."

  sudo yum update
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

# Step 3: Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Step 4: Verify Docker installation
echo "Docker version:"
sudo docker --version

# Step 5: Add users to the docker group
echo "Adding users to docker group..."
for user in jenkins ubuntu; do
  if id "$user" &>/dev/null; then
    sudo usermod -aG docker "$user"
    echo "✅ Added $user to docker group"
  else
    echo "⚠️ User $user does not exist, skipping..."
  fi
done

# Refresh group for current shell (only works interactively)
echo "To refresh group membership, please log out and back in or run: newgrp docker"

# Step 6: Pull latest SonarQube (LTS Community) image and run container
echo "Pulling latest SonarQube LTS Community image..."
sudo docker pull sonarqube:lts-community

echo "Running SonarQube on port 9000..."
sudo docker run -d --name SonarQube -p 9000:9000 sonarqube:lts-community

echo "✅ SonarQube is now running at http://localhost:9000"
