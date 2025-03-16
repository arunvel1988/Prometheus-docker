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

# Function to display running containers with an index
list_containers_with_index() {
    echo "📋 Fetching running containers..."
    containers=($(docker ps --format "{{.ID}}:{{.Names}}"))

    if [ ${#containers[@]} -eq 0 ]; then
        echo "⚠️ No running containers found!"
        sleep 2
        return 1
    fi

    echo "===================================="
    echo "   🛑 Running Containers   "
    echo "===================================="
    for i in "${!containers[@]}"; do
        container_id=$(echo "${containers[$i]}" | cut -d':' -f1)
        container_name=$(echo "${containers[$i]}" | cut -d':' -f2)
        printf "%d️⃣  %s (%s)\n" "$((i+1))" "$container_name" "$container_id"
    done
    echo "===================================="

    return 0
}

# Function to stop a specific container
stop_container() {
    list_containers_with_index || return

    read -p "👉 Enter the container number to stop: " index
    container_name=$(echo "${containers[$((index-1))]}" | cut -d':' -f2 2>/dev/null)

    if [ -z "$container_name" ]; then
        echo "❌ Invalid selection!"
    else
        echo "🛑 Stopping container: $container_name ..."
        docker stop "$container_name"
    fi

    sleep 2
}

# Function to start a stopped container
start_container() {
    echo "📋 Fetching stopped containers..."
    containers=($(docker ps -a --filter "status=exited" --format "{{.ID}}:{{.Names}}"))

    if [ ${#containers[@]} -eq 0 ]; then
        echo "⚠️ No stopped containers found!"
        sleep 2
        return
    fi

    echo "===================================="
    echo "   🚀 Stopped Containers   "
    echo "===================================="
    for i in "${!containers[@]}"; do
        container_id=$(echo "${containers[$i]}" | cut -d':' -f1)
        container_name=$(echo "${containers[$i]}" | cut -d':' -f2)
        printf "%d️⃣  %s (%s)\n" "$((i+1))" "$container_name" "$container_id"
    done
    echo "===================================="

    read -p "👉 Enter the container number to start: " index
    container_name=$(echo "${containers[$((index-1))]}" | cut -d':' -f2 2>/dev/null)

    if [ -z "$container_name" ]; then
        echo "❌ Invalid selection!"
    else
        echo "🚀 Starting container: $container_name ..."
        docker start "$container_name"
    fi

    sleep 2
}

# Function to show logs of a container
view_logs() {
    list_containers_with_index || return

    read -p "👉 Enter the container number to view logs: " index
    container_name=$(echo "${containers[$((index-1))]}" | cut -d':' -f2 2>/dev/null)

    if [ -z "$container_name" ]; then
        echo "❌ Invalid selection!"
    else
        echo "📜 Showing logs for container: $container_name ..."
        docker logs -f "$container_name"
    fi
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
    echo "4️⃣  Start a Stopped Container"
    echo "5️⃣  View Logs of a Container"
    echo "6️⃣  List Running Containers"
    echo "7️⃣  Exit"
    echo "===================================="

    read -p "👉 Enter your choice: " choice

    case $choice in
        1) deploy_app ;;
        2) stop_app ;;
        3) stop_container ;;
        4) start_container ;;
        5) view_logs ;;
        6) list_containers_with_index; sleep 3 ;;
        7) echo "👋 Exiting..."; exit 0 ;;
        *) echo "❌ Invalid choice! Please try again."; sleep 2 ;;
    esac

    echo "🔄 Press Enter to continue..."
    read
done
