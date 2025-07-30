#!/bin/bash

# === Docker & SonarQube Setup Script ===
# Supports: Ubuntu, Debian, Amazon Linux, CentOS
# Includes: Non-interactive mode (-y), user-friendly messages, fixed repo handling

# --- Detect OS ---
OS=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
echo -e "\n📦 Detected OS: $OS\n"

# --- Remove Conflicting Docker Packages (Ubuntu/Debian) ---
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  echo "🔧 Removing existing Docker-related packages..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg"
  done
fi

# --- Install Docker ---
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  echo "📥 Installing Docker on Ubuntu/Debian..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  echo "🔑 Adding Docker GPG key..."
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "📦 Setting up Docker repo..."
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

elif [[ "$OS" == "amzn" || "$OS" == "centos" ]]; then
  echo "📥 Installing Docker on Amazon Linux / CentOS..."
  sudo yum update -y
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

# --- Start Docker ---
echo "🚀 Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# --- Verify Docker ---
echo "🧪 Verifying Docker installation:"
docker --version || { echo "❌ Docker installation failed"; exit 1; }

# --- Add Common Users to Docker Group ---
echo "👤 Adding users to docker group..."
for user in jenkins ubuntu; do
  if id "$user" &>/dev/null; then
    sudo usermod -aG docker "$user"
    echo "✅ Added $user to docker group"
  else
    echo "⚠️  User $user does not exist, skipping..."
  fi
done

echo "🔄 Please log out and back in or run 'newgrp docker' to apply group changes."

# --- Pull & Run SonarQube ---
echo "📦 Pulling SonarQube LTS Community image..."
sudo docker pull sonarqube:lts-community

echo "🚀 Running SonarQube on port 9000..."
sudo docker run -d --name SonarQube -p 9000:9000 sonarqube:lts-community

echo -e "\n✅ SonarQube is now running at: http://localhost:9000\n"
