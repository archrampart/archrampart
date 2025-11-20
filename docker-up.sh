#!/bin/bash

###############################################################################
# ArchRampart Audit Tool - Single Command Docker Startup
# 
# This script starts the application using Docker Compose.
###############################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ArchRampart Audit Tool - Docker Startup               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}❌ Docker not found!${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}❌ Docker Compose not found!${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Docker Compose command (old or new version)
DOCKER_COMPOSE="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
fi

# Check .env file (optional)
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}ℹ️  .env file not found. Using default settings.${NC}"
    echo "   You can create a .env file for customization (see README.md)"
    echo ""
fi

echo -e "${YELLOW}[1/3]${NC} Building Docker images..."
$DOCKER_COMPOSE build
echo ""

echo -e "${YELLOW}[2/3]${NC} Starting services..."
$DOCKER_COMPOSE up -d
echo ""

echo -e "${YELLOW}[3/3]${NC} Checking service status..."
sleep 3
$DOCKER_COMPOSE ps
echo ""

# IP address
IP=$(hostname -I | awk '{print $1}' || echo "localhost")

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              APPLICATION STARTED!                           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "📱 Access Information:"
echo -e "   Frontend:  ${BLUE}http://${IP}:5173${NC}"
echo -e "   Backend:   ${BLUE}http://${IP}:8000${NC}"
echo -e "   API Docs:  ${BLUE}http://${IP}:8000/docs${NC}"
echo ""
echo -e "👤 Default Admin User:"
echo -e "   Email:     ${BLUE}admin@archrampart.com${NC}"
echo -e "   Password:  ${BLUE}admin123${NC}"
echo ""
echo -e "📋 Commands:"
echo -e "   Logs:      ${BLUE}$DOCKER_COMPOSE logs -f${NC}"
echo -e "   Stop:      ${BLUE}$DOCKER_COMPOSE down${NC}"
echo -e "   Restart:   ${BLUE}$DOCKER_COMPOSE restart${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Database migrations and templates will be created on first startup."
echo -e "      This process may take a few minutes."
echo ""
