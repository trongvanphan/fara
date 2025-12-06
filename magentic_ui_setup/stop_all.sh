#!/bin/bash

# Stop All: FARA-7B Server + Magentic-UI
# Dừng toàn bộ hệ thống

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FARA_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================================"
echo "  Stopping FARA-7B + Magentic-UI"
echo "================================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Stop Magentic-UI
echo ""
echo "Stopping Magentic-UI..."
pkill -f "magentic-ui" 2>/dev/null && echo -e "${GREEN}✓ Magentic-UI stopped${NC}" || echo "  Magentic-UI was not running"

# Stop FARA server
echo ""
echo "Stopping FARA server..."
if [ -f "$FARA_DIR/stop_fara_server.sh" ]; then
    cd "$FARA_DIR"
    ./stop_fara_server.sh 2>/dev/null && echo -e "${GREEN}✓ FARA server stopped${NC}" || echo "  FARA server was not running"
else
    # Try to kill any process on port 8000
    PID=$(lsof -ti:8000 2>/dev/null)
    if [ -n "$PID" ]; then
        kill $PID 2>/dev/null
        echo -e "${GREEN}✓ Killed process on port 8000 (PID: $PID)${NC}"
    else
        echo "  No process found on port 8000"
    fi
fi

# Also try to kill vllm processes
pkill -f "vllm" 2>/dev/null && echo -e "${GREEN}✓ VLLM processes stopped${NC}" || true
pkill -f "llama-server" 2>/dev/null && echo -e "${GREEN}✓ llama-server stopped${NC}" || true

echo ""
echo "================================================"
echo -e "${GREEN}  All services stopped${NC}"
echo "================================================"
