#!/bin/bash

# ==============================================================================
#           Ollama and Open WebUI Docker Installation Script (v2)
#
# This script automates the installation and configuration of:
#   1. Ollama (The LLM runner), configured to accept network connections.
#   2. Docker Engine (The containerization platform).
#   3. Open WebUI (A web interface for Ollama, running in Docker).
#
# It is designed for Debian-based Linux distributions (like Ubuntu) and
# is optimized to handle common WSL networking issues.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
WEBUI_CONTAINER_NAME="ollama-webui"
WEBUI_HOST_PORT="3000"

# --- Helper Functions ---
print_info() {
    echo -e "\n\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

# --- Installation Functions ---

# Function to install and configure Ollama
install_ollama() {
    print_info "Checking for Ollama..."
    if command -v ollama &> /dev/null; then
        print_success "Ollama is already installed. Skipping installation."
    else
        print_info "Ollama not found. Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sudo sh
        print_success "Ollama installation complete."
    fi

    # --- [NEW] Configure Ollama to accept connections from the Docker container ---
    print_info "Configuring Ollama to accept remote connections..."
    local override_dir="/etc/systemd/system/ollama.service.d"
    local override_file="${override_dir}/override.conf"
    
    sudo mkdir -p "$override_dir"
    
    # Create the override file to set OLLAMA_HOST
    # This ensures Ollama listens on all network interfaces
    echo "[Service]" | sudo tee "$override_file" > /dev/null
    echo "Environment=\"OLLAMA_HOST=0.0.0.0\"" | sudo tee -a "$override_file" > /dev/null
    
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    print_success "Ollama is now configured to listen on 0.0.0.0."
}

# Function to install Docker
install_docker() {
    print_info "Checking for Docker..."
    if command -v docker &> /dev/null; then
        print_success "Docker is already installed. Skipping installation."
    else
        print_info "Docker not found. Installing Docker Engine..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
        print_success "Docker installation complete."
    fi

    sudo systemctl enable --now docker
    print_success "Docker service is active."
}

# Function to deploy the Open WebUI Docker container
run_webui_container() {
    print_info "Setting up Open WebUI Docker container (Name: ${WEBUI_CONTAINER_NAME})..."

    if [ "$(sudo docker ps -q -f name=^/${WEBUI_CONTAINER_NAME}$)" ]; then
        print_success "Container '${WEBUI_CONTAINER_NAME}' is already running."
        return
    fi

    if [ "$(sudo docker ps -aq -f status=exited -f name=^/${WEBUI_CONTAINER_NAME}$)" ]; then
        print_info "Found a stopped '${WEBUI_CONTAINER_NAME}' container. Starting it..."
        sudo docker start ${WEBUI_CONTAINER_NAME}
        print_success "Container started."
        return
    fi

    print_info "Pulling the latest Open WebUI image..."
    sudo docker pull ghcr.io/open-webui/open-webui:main

    print_info "Launching new Open WebUI container..."
    sudo docker run -d \
        -p ${WEBUI_HOST_PORT}:8080 \
        --add-host=host.docker.internal:host-gateway \
        -v open-webui:/app/backend/data \
        --name ${WEBUI_CONTAINER_NAME} \
        --restart always \
        ghcr.io/open-webui/open-webui:main

    print_info "Waiting a few seconds for the container to initialize..."
    sleep 5
    sudo docker ps -f name=^/${WEBUI_CONTAINER_NAME}$
    print_success "Open WebUI container is now running."
}

# --- Main Execution ---
main() {
    print_info "Starting the setup process for Ollama and Open WebUI."
    
    install_ollama
    install_docker
    run_webui_container

    # --- [NEW] Detect the Docker Host IP for more reliable instructions ---
    DOCKER_HOST_IP=$(ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    
    echo
    print_success "All steps completed!"
    echo "------------------------------------------------------------------"
    echo "You can now access the Open WebUI in your browser:"
    echo -e "\t\033[1;36mhttp://localhost:${WEBUI_HOST_PORT}\033[0m"
    echo
    echo "IMPORTANT FIRST STEPS:"
    echo "1. The first account you create on the WebUI will be the admin account."
    echo "2. After logging in, go to Settings -> Connections."
    echo "3. Set the 'Ollama API Base URL'. For WSL, use the detected IP:"
    echo
    echo -e "   \033[1;32mRECOMMENDED FOR WSL:\033[0m \033[1;33mhttp://${DOCKER_HOST_IP}:11434\033[0m"
    echo
    echo "   (If that fails, you can try the standard Docker method: http://host.docker.internal:11434)"
    echo "------------------------------------------------------------------"
    echo "NOTE: You may need a Windows Firewall rule to allow connections on port 11434 for this to work."
    echo "------------------------------------------------------------------"
}

# Run the main function
main
