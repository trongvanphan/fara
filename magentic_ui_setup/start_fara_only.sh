#!/bin/bash

# Start FARA-Only: Chỉ dùng FARA-7B cho TẤT CẢ agents
# Không cần OpenAI, không cần Ollama - chỉ cần FARA server!

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FARA_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================================"
echo "  🚀 FARA-7B Only Mode"
echo "  Sử dụng FARA cho TẤT CẢ agents!"
echo "================================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Step 1: Start FARA Server
echo ""
echo -e "${BLUE}Step 1: Starting FARA-7B Server...${NC}"
echo "================================================"

if check_port 8000; then
    echo -e "${GREEN}✓ FARA server already running on port 8000${NC}"
else
    echo "Starting FARA server..."
    cd "$FARA_DIR"
    
    if [ -f "start_fara_server.sh" ]; then
        ./start_fara_server.sh &
        
        echo "Waiting for FARA server..."
        MAX_WAIT=120
        WAIT_COUNT=0
        while ! check_port 8000; do
            if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
                echo -e "${RED}❌ FARA server failed to start within ${MAX_WAIT}s${NC}"
                exit 1
            fi
            sleep 2
            WAIT_COUNT=$((WAIT_COUNT + 2))
            echo "  Waiting... ($WAIT_COUNT/${MAX_WAIT}s)"
        done
        echo -e "${GREEN}✓ FARA server is ready on port 8000${NC}"
    else
        echo -e "${RED}❌ start_fara_server.sh not found${NC}"
        echo "Please start FARA server manually first."
        exit 1
    fi
fi

# Verify FARA server
echo ""
echo "Verifying FARA server..."
if curl -s http://localhost:8000/v1/models >/dev/null 2>&1; then
    echo -e "${GREEN}✓ FARA server is responding${NC}"
else
    echo -e "${YELLOW}⚠️  FARA server on port 8000 but not responding yet${NC}"
    echo "   Model may still be loading. Continuing..."
fi

# Step 2: Check Magentic-UI
echo ""
echo -e "${BLUE}Step 2: Checking Magentic-UI...${NC}"
echo "================================================"

if ! command -v magentic-ui &> /dev/null; then
    echo -e "${RED}❌ magentic-ui not installed${NC}"
    echo "Run: ./install_magentic_ui.sh"
    exit 1
fi
echo -e "${GREEN}✓ Magentic-UI is installed${NC}"

# Step 3: Start Magentic-UI with FARA-only config
echo ""
echo -e "${BLUE}Step 3: Starting Magentic-UI (FARA-only mode)...${NC}"
echo "================================================"

CONFIG_FILE="$SCRIPT_DIR/fara_only_config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

echo "Using config: $CONFIG_FILE"

if check_port 8081; then
    echo -e "${YELLOW}⚠️  Port 8081 already in use${NC}"
    echo "   Magentic-UI might already be running."
else
    echo "Starting Magentic-UI..."
    magentic-ui --port 8081 --config "$CONFIG_FILE" &
    sleep 5
    
    if check_port 8081; then
        echo -e "${GREEN}✓ Magentic-UI is running${NC}"
    else
        echo -e "${YELLOW}⚠️  Magentic-UI is starting...${NC}"
    fi
fi

# Summary
echo ""
echo "================================================"
echo -e "${GREEN}  🎉 FARA-Only System Started!${NC}"
echo "================================================"
echo ""
echo "  Architecture:"
echo "  ┌─────────────────────────────────────────┐"
echo "  │           Magentic-UI                   │"
echo "  │  ┌─────────┐ ┌─────────┐ ┌───────────┐  │"
echo "  │  │Orchestr.│ │  Coder  │ │File Surfer│  │"
echo "  │  │ (FARA)  │ │ (FARA)  │ │  (FARA)   │  │"
echo "  │  └────┬────┘ └────┬────┘ └─────┬─────┘  │"
echo "  │       └───────────┼────────────┘        │"
echo "  │  ┌────────────────┴────────────────┐    │"
echo "  │  │        Web Surfer (FARA)        │    │"
echo "  │  └─────────────────────────────────┘    │"
echo "  └─────────────────────────────────────────┘"
echo "                      │"
echo "                      ▼"
echo "  ┌─────────────────────────────────────────┐"
echo "  │      FARA-7B Server (port 8000)         │"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "  Services:"
echo "  ├── FARA-7B:       http://localhost:8000"
echo "  └── Magentic-UI:   http://localhost:8081"
echo ""
echo -e "  ${GREEN}✓ Không cần OpenAI API key!${NC}"
echo -e "  ${GREEN}✓ Không cần Ollama!${NC}"
echo -e "  ${YELLOW}⚠️  Lưu ý: FARA được tối ưu cho web browsing${NC}"
echo -e "  ${YELLOW}   Có thể không tối ưu cho coding tasks${NC}"
echo ""
echo "  Open: ${BLUE}http://localhost:8081${NC}"
echo ""
echo "  To stop: ./stop_all.sh"
echo "================================================"
