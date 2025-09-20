# ollama_webui_install
Ollama &amp; Open WebUI Quick Setup for WSL/Linux

Ollama & Open WebUI Quick Setup for WSL/Linux

This script automates the complete setup of a local Large Language Model (LLM) environment on Debian-based Linux systems like Ubuntu. It installs Ollama, Docker, and deploys the Open WebUI in a container.

Most importantly, this script is specifically designed to handle the common networking challenges encountered when running this stack inside the Windows Subsystem for Linux (WSL). It automatically configures Ollama to accept connections from Docker containers and provides tailored instructions for a seamless setup.
Key Features

    Automated Installation: Installs Ollama and Docker Engine if they are not already present.

    Intelligent Configuration: Automatically configures the Ollama systemd service to listen on all network interfaces (0.0.0.0), solving the "localhost" connection issue with Docker on WSL out-of-the-box.

    WebUI Deployment: Pulls the latest open-webui Docker image and runs it as a persistent, auto-restarting container.

    User-Friendly Instructions: Finishes by providing the correct, dynamically detected IP address for connecting the WebUI to Ollama within a WSL environment.

Why Use This Script?

By default, the Ollama server only listens for requests from localhost (127.0.0.1). A Docker container has its own isolated network and cannot reach localhost on the host machine. This means a standard installation will fail to connect.

This script automates the necessary fix by creating a systemd override that forces Ollama to listen for connections from any network, including the virtual network used by Docker in WSL.
Prerequisites

    A Debian-based Linux system (e.g., Ubuntu 20.04+).

    Designed and tested for Windows Subsystem for Linux (WSL2), but works on standard Linux desktops as well.

    sudo (administrator) privileges.

    curl and ip commands (installed by default on most systems).

Usage

    Clone the repository or download the script.

        Using Git:

        git clone <your-repo-url>
        cd <your-repo-name>

        Using curl:

        curl -O https://<raw-github-url-to-your-script>/install_ollama_webui_v2.sh

    Make the script executable:

    chmod +x install_ollama_webui_v2.sh

    Run the script:

    ./install_ollama_webui_v2.sh

    The script will prompt for your password when sudo commands are run. Follow the on-screen information as it installs and configures the services.

Post-Installation Steps

Once the script is finished, it will display a success message with the final instructions.

    Open your web browser on your Windows host and navigate to: http://localhost:3000

    The first account you create will automatically become the administrator account.

    After logging in, go to Settings -> Connections.

    Set the Ollama API Base URL to the IP address recommended by the script. It will look something like this:
    http://172.17.0.1:11434

    Click "Save" and navigate back to the main chat screen. Click the refresh icon next to the model selector, and your locally installed Ollama models should now appear!

🚨 Troubleshooting: The Windows Firewall

If you have followed all the steps and the WebUI still cannot connect to Ollama, the Windows Defender Firewall is the most likely culprit. It often blocks connections from WSL to the host on specific ports.

You must create a new Inbound Rule on your Windows machine to allow this connection.

    Open Windows Defender Firewall with Advanced Security.

    Click on Inbound Rules -> New Rule...

    Rule Type: Select Port.

    Protocol and Ports: Select TCP and enter 11434 in "Specific local ports".

    Action: Select Allow the connection.

    Profile: Keep all three (Domain, Private, Public) checked.

    Name: Give it a descriptive name like Ollama WSL Access.

You do not need to restart WSL or Docker. This change takes effect immediately. Try connecting the WebUI again.
License

This project is licensed under the MIT License.
