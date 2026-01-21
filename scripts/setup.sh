#!/bin/bash
set -e

APP_DIR="/opt/backend"
REPO_URL="https://github.com/manojthakurkkr/backend.git"

FRONT_APP_DIR="/opt/frontend"
FRONT_REPO_URL="https://github.com/manojthakurkkr/frontend.git"
START_FILE="index.js"

echo "===== Updating system ====="
sudo apt update -y

echo "===== Installing system dependencies ====="
sudo apt install -y \
  git \
  curl \
  python3 \
  python3-pip \
  python3-venv \
  python3-full \
  build-essential

echo "===== Cloning Python project ====="
mkdir -p /opt
cd /opt

if [ ! -d "$APP_DIR" ]; then
  git clone $REPO_URL backend
fi

cd $APP_DIR

echo "===== Creating Python virtual environment ====="
python3 -m venv venv
source venv/bin/activate

echo "===== Upgrading pip ====="
pip install --upgrade pip

echo "===== Installing Python dependencies ====="
if [ -f requirements.txt ]; then
  pip install -r requirements.txt --break-system-packages
else
  echo "requirements.txt not found"
fi
python3 app.py &
echo "===== Python Setup Completed Successfully ====="


sudo apt update

echo "===== Setting up Frontend Environment ====="
sudo apt install -y nodejs npm
node -v
npm -v
echo "===== Cloning Frontend project ====="
cd ..
git clone $FRONT_REPO_URL frontend
echo "===== Setting up Frontend project ====="
cd frontend
npm install
node index.js &
echo "===== Frontend Setup Completed Successfully ====="



#!/bin/bash

# 1. Update system and install Git
#apt-get update -y
# apt-get install -y git apt-transport-https ca-certificates curl software-properties-common

# # 2. Install Docker
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# apt-get update -y
# apt-get install -y docker-ce

# # 3. Start Docker and ensure it runs on boot
# systemctl start docker
# systemctl enable docker

# # 4. Add the default user to the docker group so you can run docker without sudo later
# usermod -aG docker ubuntu

# 5. Clone the repository
#cd /home/ubuntu
#git clone https://github.com/manojthakurkkr/backend.git
#cd backend

# 6. Build the Docker Image
# Ensure you have a 'Dockerfile' in your repository root
#docker build -t backend .

# 7. Run the Docker Container
# Maps port 80 on the EC2 to port 5000 (or whatever your app uses) in the container
#docker run -d --name backend -p 5000:5000 --restart always backend

cd ..
#git clone https://github.com/manojthakurkkr/frontend.git
#cd frontend

# 6. Build the Docker Image
# Ensure you have a 'Dockerfile' in your repository root
#docker build -t frontend .

# 7. Run the Docker Container
# Maps port 80 on the EC2 to port 5000 (or whatever your app uses) in the container
#docker run -d --name frontend -p 3000:3000 --restart always frontend