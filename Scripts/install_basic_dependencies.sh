#!/bin/bash

# Script that installs Java, Python, Docker. 

# Function to install Java
install_java() {
    echo "Installing Java..."
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt-get update -y
        sudo apt-get install openjdk-11-jdk -y
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
        sudo yum install java-11-openjdk-devel -y
    elif [[ "$DISTRO" == "amzn" ]]; then
        sudo yum install java-11-amazon-corretto -y
    else
        echo "Unsupported distribution for Java installation."
        exit 1
    fi
    echo "Java installed successfully."
}

# Function to install Python
install_python() {
    echo "Installing Python..."
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt-get update -y
        sudo apt-get install python3 -y
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
        sudo yum install python3 -y
    elif [[ "$DISTRO" == "amzn" ]]; then
        sudo yum install python3 -y
    else
        echo "Unsupported distribution for Python installation."
        exit 1
    fi
    echo "Python installed successfully."
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt-get update -y
        sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update -y
        sudo apt-get install docker-ce -y
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install docker-ce docker-ce-cli containerd.io -y
        sudo systemctl start docker
        sudo systemctl enable docker
    elif [[ "$DISTRO" == "amzn" ]]; then
        sudo amazon-linux-extras install docker -y
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Unsupported distribution for Docker installation."
        exit 1
    fi
    echo "Docker installed successfully."
}

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$(echo $ID | tr '[:upper:]' '[:lower:]')
else
    echo "Cannot detect the Linux distribution."
    exit 1
fi

echo "Detected Linux distribution: $DISTRO"

# Install Java
install_java

# Install Python
install_python

# Install Docker
install_docker

echo "All installations are complete."