#!/bin/bash

# Start All: FARA-7B Server + Magentic-UI
# Khởi động toàn bộ hệ thống để chạy FARA với Magentic-UI

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FARA_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================================"
echo "  FARA-7B + Magentic-UI Startup Script"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  Warning: OPENAI_API_KEY not set${NC}"
    echo "   Orchestrator, Coder, and File Surfer will not work without it."
    echo "   Set it with: export OPENAI_API_KEY='your-key'"
    echo ""
fi

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Step 1: Start FARA Server
echo ""
echo -e "${GREEN}Step 1: Starting FARA-7B Server...${NC}"
echo "================================================"

if check_port 8000; then
    echo -e "${YELLOW}✓ FARA server already running on port 8000${NC}"
else
    echo "Starting FARA server..."
    cd "$FARA_DIR"
    
    # Check which method to use
    if [ -f "start_fara_server.sh" ]; then
        ./start_fara_server.sh &
        FARA_PID=$!
        echo "FARA server starting (PID: $FARA_PID)..."
    else
        echo -e "${RED}Error: start_fara_server.sh not found${NC}"
        echo "Please start FARA server manually first."
        exit 1
    fi
    
    # Wait for FARA server to be ready
    echo "Waiting for FARA server to be ready..."
    MAX_WAIT=120
    WAIT_COUNT=0
    while ! check_port 8000; do
        if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
            echo -e "${RED}Error: FARA server failed to start within ${MAX_WAIT}s${NC}"
            exit 1
        fi
        sleep 2
        WAIT_COUNT=$((WAIT_COUNT + 2))
        echo "  Waiting... ($WAIT_COUNT/${MAX_WAIT}s)"
    done
    echo -e "${GREEN}✓ FARA server is ready on port 8000${NC}"
fi

# Verify FARA server is responding
echo ""
echo "Verifying FARA server..."
if curl -s http://localhost:8000/v1/models >/dev/null 2>&1; then
    echo -e "${GREEN}✓ FARA server is responding${NC}"
else
    echo -e "${YELLOW}⚠️  FARA server on port 8000 but not responding to API calls${NC}"
    echo "   This might be normal during model loading. Continuing..."
fi

# Step 2: Check Magentic-UI installation
echo ""
echo -e "${GREEN}Step 2: Checking Magentic-UI...${NC}"
echo "================================================"

if ! command -v magentic-ui &> /dev/null; then
    echo -e "${RED}Error: magentic-ui not found${NC}"
    echo "Install it with: pip install magentic-ui --upgrade"
    exit 1
fi
echo -e "${GREEN}✓ Magentic-UI is installed${NC}"

# Step 3: Start Magentic-UI
echo ""
echo -e "${GREEN}Step 3: Starting Magentic-UI...${NC}"
echo "================================================"

CONFIG_FILE="$SCRIPT_DIR/fara_config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

echo "Using config: $CONFIG_FILE"
echo ""

if check_port 8081; then
    echo -e "${YELLOW}⚠️  Port 8081 is already in use${NC}"
    echo "   Magentic-UI might already be running."
    echo "   Access it at: http://localhost:8081"
else
    echo "Starting Magentic-UI on port 8081..."
    magentic-ui --port 8081 --config "$CONFIG_FILE" &
    MAGENTIC_PID=$!
    
    # Wait a bit for startup
    sleep 5
    
    if check_port 8081; then
        echo -e "${GREEN}✓ Magentic-UI is running (PID: $MAGENTIC_PID)${NC}"
    else
        echo -e "${YELLOW}⚠️  Magentic-UI is starting... this may take a moment${NC}"
    fi
fi

# Final summary
echo ""
echo "================================================"
echo -e "${GREEN}  🚀 System Started Successfully!${NC}"
echo "================================================"
echo ""
echo "  FARA-7B Server:  http://localhost:8000"
echo "  Magentic-UI:     http://localhost:8081"
echo ""
echo "  Open http://localhost:8081 in your browser"
echo "  to start using FARA-7B with Magentic-UI!"
echo ""
echo "  To stop all services: ./stop_all.sh"
echo "================================================"

# Keep script running to show logs (optional)
# Uncomment the following line to tail logs
# wait
