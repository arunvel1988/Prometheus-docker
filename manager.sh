#!/bin/bash

# Function to deploy the application
deploy_app() {
    echo "🚀 Deploying the application..."
    docker-compose up -d --build
}

# Function to stop the application
stop_app() {
    echo "🛑 Stopping the entire application..."
    docker-compose down
}

# Function to stop a specific container (Dynamic Selection)
stop_container() {
    echo "📋 Fetching running containers..."
    containers=$(docker ps --format "{{.ID}} {{.Names}}")
    
    if [ -z "$containers" ]; then
        echo "⚠️ No running containers found!"
        sleep 2
        return
    fi

    echo "===================================="
    echo "   🛑 Stop a Running Container   "
    echo "===================================="
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    echo "===================================="

    read -p "👉 Enter the container name to stop: " container_name

    if [ -z "$container_name" ]; then
        echo "❌ No container name entered!"
    else
        echo "🛑 Stopping container: $container_name ..."
        docker stop "$container_name"
    fi

    sleep 2
}

# Function to list running containers
list_containers() {
    echo "📋 Listing running containers..."
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    sleep 3
}

# Main menu loop
while true; do
    clear
    echo "===================================="
    echo "   🚀 Docker Application Manager   "
    echo "===================================="
    echo "1️⃣  Deploy Application"
    echo "2️⃣  Stop Application"
    echo "3️⃣  Stop a Running Container"
    echo "4️⃣  List Running Containers"
    echo "5️⃣  Exit"
    echo "===================================="

    read -p "👉 Enter your choice: " choice

    case $choice in
        1) deploy_app ;;
        2) stop_app ;;
        3) stop_container ;;
        4) list_containers ;;
        5) echo "👋 Exiting..."; exit 0 ;;
        *) echo "❌ Invalid choice! Please try again."; sleep 2 ;;
    esac

    echo "🔄 Press Enter to continue..."
    read
done
