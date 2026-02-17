#!/bin/bash
# ═══════════════════════════════════════════════════════
#  EC2 Setup Script — Run this ONCE on any new EC2 instance
#  Usage: bash setup.sh YOUR_DOCKERHUB_USERNAME
# ═══════════════════════════════════════════════════════

DOCKER_USERNAME=${1:-"chandan240603"}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 AWS DevOps Todo — EC2 Setup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1 — Update packages
echo "📦 Updating packages..."
sudo apt update && sudo apt upgrade -y

# Step 2 — Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
rm get-docker.sh

# Step 3 — Install Docker Compose
echo "🔧 Installing Docker Compose..."
sudo apt install docker-compose -y

# Step 4 — Clone the repo
echo "📂 Cloning repository..."
mkdir -p ~/app
cd ~/app
git clone https://github.com/Chandangadewar/aws-devops-todo.git .

# Step 5 — Create .env file
echo "⚙️  Creating environment file..."
echo "DOCKER_USERNAME=${DOCKER_USERNAME}" > .env

# Step 6 — Apply docker group without logout
echo "🔑 Applying docker permissions..."
newgrp docker << EOF

# Step 7 — Pull and start containers
echo "🚀 Starting containers..."
cd ~/app
docker-compose pull
docker-compose up -d

# Verify
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker ps
echo ""
curl -s http://localhost/api/health
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Setup Complete!"
echo "  🌍 App running at: http://\$(curl -s ifconfig.me)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOF
