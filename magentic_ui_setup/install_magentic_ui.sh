#!/bin/bash

# Install Magentic-UI and dependencies
# Script cài đặt Magentic-UI

set -e

echo "================================================"
echo "  Installing Magentic-UI"
echo "================================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Python version
echo ""
echo "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
    echo -e "${RED}Error: Python 3.10+ required. Found: $PYTHON_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python $PYTHON_VERSION${NC}"

# Check Docker
echo ""
echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker not found${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker Desktop first."
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Install magentic-ui
echo ""
echo "Installing magentic-ui..."
pip install magentic-ui --upgrade

# Install playwright browsers
echo ""
echo "Installing Playwright browsers..."
playwright install

# Verify installation
echo ""
echo "Verifying installation..."
if command -v magentic-ui &> /dev/null; then
    echo -e "${GREEN}✓ magentic-ui installed successfully${NC}"
    magentic-ui --version 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  magentic-ui command not found in PATH${NC}"
    echo "   Try: python -m magentic_ui"
fi

echo ""
echo "================================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Set your OpenAI API key:"
echo "     export OPENAI_API_KEY='your-api-key'"
echo ""
echo "  2. Start FARA server (if not already running)"
echo ""
echo "  3. Run: ./start_all.sh"
echo ""
echo "  4. Open: http://localhost:8081"
echo "================================================"
