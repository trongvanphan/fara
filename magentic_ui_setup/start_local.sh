#!/bin/bash

# Start All LOCAL: FARA-7B + Ollama + Magentic-UI
# Chạy hoàn toàn local, KHÔNG cần OpenAI API key

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FARA_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================================"
echo "  🏠 FARA + Magentic-UI (100% LOCAL)"
echo "  Không cần OpenAI API key!"
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

# Step 1: Check và start Ollama
echo ""
echo -e "${BLUE}Step 1: Checking Ollama...${NC}"
echo "================================================"

if ! command -v ollama &> /dev/null; then
    echo -e "${RED}❌ Ollama not installed${NC}"
    echo ""
    echo "Cài đặt Ollama:"
    echo "  macOS:   brew install ollama"
    echo "  Linux:   curl -fsSL https://ollama.com/install.sh | sh"
    echo "  Website: https://ollama.com/download"
    echo ""
    exit 1
fi

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "Starting Ollama..."
    ollama serve &
    sleep 3
fi

if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Ollama is running on port 11434${NC}"
else
    echo -e "${RED}❌ Failed to start Ollama${NC}"
    exit 1
fi

# Check/pull required model
OLLAMA_MODEL="qwen2.5:7b"
echo ""
echo "Checking model: $OLLAMA_MODEL"

if ollama list | grep -q "$OLLAMA_MODEL"; then
    echo -e "${GREEN}✓ Model $OLLAMA_MODEL available${NC}"
else
    echo -e "${YELLOW}⚠️  Model $OLLAMA_MODEL not found${NC}"
    echo ""
    read -p "Do you want to download $OLLAMA_MODEL now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Downloading $OLLAMA_MODEL (this may take a while)..."
        ollama pull $OLLAMA_MODEL
    else
        echo ""
        echo "You can use a different model by editing local_only_config.yaml"
        echo "Available models: ollama list"
        echo ""
        echo "Smaller alternatives:"
        echo "  - qwen2.5:7b (4GB)"
        echo "  - llama3.1:8b (5GB)"
        echo "  - mistral:7b (4GB)"
        echo ""
    fi
fi

# Step 2: Start FARA Server
echo ""
echo -e "${BLUE}Step 2: Starting FARA-7B Server...${NC}"
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
                echo -e "${RED}❌ FARA server failed to start${NC}"
                exit 1
            fi
            sleep 2
            WAIT_COUNT=$((WAIT_COUNT + 2))
            echo "  Waiting... ($WAIT_COUNT/${MAX_WAIT}s)"
        done
        echo -e "${GREEN}✓ FARA server is ready${NC}"
    else
        echo -e "${RED}❌ start_fara_server.sh not found${NC}"
        exit 1
    fi
fi

# Step 3: Start Magentic-UI
echo ""
echo -e "${BLUE}Step 3: Starting Magentic-UI...${NC}"
echo "================================================"

if ! command -v magentic-ui &> /dev/null; then
    echo -e "${RED}❌ magentic-ui not installed${NC}"
    echo "Run: ./install_magentic_ui.sh"
    exit 1
fi

CONFIG_FILE="$SCRIPT_DIR/local_only_config.yaml"

if check_port 8081; then
    echo -e "${YELLOW}⚠️  Port 8081 already in use${NC}"
else
    echo "Starting Magentic-UI with local config..."
    magentic-ui --port 8081 --config "$CONFIG_FILE" &
    sleep 5
    
    if check_port 8081; then
        echo -e "${GREEN}✓ Magentic-UI is running${NC}"
    fi
fi

# Summary
echo ""
echo "================================================"
echo -e "${GREEN}  🎉 100% LOCAL System Started!${NC}"
echo "================================================"
echo ""
echo "  Services:"
echo "  ├── Ollama:        http://localhost:11434"
echo "  ├── FARA-7B:       http://localhost:8000"
echo "  └── Magentic-UI:   http://localhost:8081"
echo ""
echo -e "  ${GREEN}✓ Không cần OpenAI API key!${NC}"
echo ""
echo "  Open: ${BLUE}http://localhost:8081${NC}"
echo ""
echo "  To stop: ./stop_all.sh"
echo "================================================"
