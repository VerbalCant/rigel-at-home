#!/bin/bash
set -e

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_help() {
    echo -e "${GREEN}Rigel@Home Development Server Control Script${NC}"
    echo
    echo "Usage: ./run.sh [command]"
    echo
    echo "Commands:"
    echo "  start       Start all services (default)"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  rebuild     Rebuild and start services"
    echo "  reset       Factory reset (removes all data, images, and volumes)"
    echo "  logs        Show logs (use ctrl+c to exit)"
    echo "  status      Show status of all services"
    echo
    echo "Examples:"
    echo "  ./run.sh            # Same as './run.sh start'"
    echo "  ./run.sh logs       # Show logs for all services"
    echo "  ./run.sh reset      # Complete factory reset"
}

compose_files="-f docker/compose.base.yml -f docker/compose.dev.yml"

start_services() {
    echo -e "${GREEN}Starting services...${NC}"
    docker compose ${compose_files} up -d
    echo -e "${GREEN}Services are starting! Use './run.sh logs' to view logs${NC}"
}

stop_services() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker compose ${compose_files} down
}

show_logs() {
    echo -e "${GREEN}Showing logs (Ctrl+C to exit)...${NC}"
    docker compose ${compose_files} logs -f
}

show_status() {
    echo -e "${GREEN}Current Status:${NC}"
    docker compose ${compose_files} ps
}

rebuild_services() {
    echo -e "${YELLOW}Rebuilding all services...${NC}"
    docker compose ${compose_files} build --no-cache
    start_services
}

factory_reset() {
    echo -e "${RED}WARNING: This will remove all data, images, and volumes!${NC}"
    read -p "Are you sure you want to continue? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo -e "${YELLOW}Performing factory reset...${NC}"
        
        # Stop all services
        docker compose ${compose_files} down -v
        
        # Remove all related images
        docker rmi $(docker images -q rigel-at-home-server) 2>/dev/null || true
        docker rmi $(docker images -q rigel-at-home-agent) 2>/dev/null || true
        
        # Prune volumes
        docker volume prune -f
        
        # Rebuild and start
        echo -e "${GREEN}Rebuilding from scratch...${NC}"
        rebuild_services
    else
        echo -e "${YELLOW}Factory reset cancelled${NC}"
    fi
}

# Main command processing
case "${1:-start}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        start_services
        ;;
    rebuild)
        rebuild_services
        ;;
    reset)
        factory_reset
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    help)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac 