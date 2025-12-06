#!/bin/bash
# Script để tắt Fara-7B server và kill các port liên quan
# Sử dụng: ./stop_fara_server.sh

echo "🛑 Stopping Fara-7B server..."

# Kill process trên port 8000 (Fara server)
PORT_8000_PID=$(lsof -ti :8000 2>/dev/null)
if [ -n "$PORT_8000_PID" ]; then
    echo "📍 Found process on port 8000: PID $PORT_8000_PID"
    kill -9 $PORT_8000_PID 2>/dev/null
    echo "✅ Killed process on port 8000"
else
    echo "ℹ️  No process found on port 8000"
fi

# Kill process trên port 5000 (backup port)
PORT_5000_PID=$(lsof -ti :5000 2>/dev/null)
if [ -n "$PORT_5000_PID" ]; then
    echo "📍 Found process on port 5000: PID $PORT_5000_PID"
    kill -9 $PORT_5000_PID 2>/dev/null
    echo "✅ Killed process on port 5000"
else
    echo "ℹ️  No process found on port 5000"
fi

# Kill tất cả llama_cpp.server processes
LLAMA_PIDS=$(pgrep -f "llama_cpp.server" 2>/dev/null)
if [ -n "$LLAMA_PIDS" ]; then
    echo "📍 Found llama_cpp.server processes: $LLAMA_PIDS"
    pkill -9 -f "llama_cpp.server" 2>/dev/null
    echo "✅ Killed all llama_cpp.server processes"
else
    echo "ℹ️  No llama_cpp.server processes found"
fi

# Kill Playwright browser processes (nếu có)
PLAYWRIGHT_PIDS=$(pgrep -f "playwright" 2>/dev/null)
if [ -n "$PLAYWRIGHT_PIDS" ]; then
    echo "📍 Found Playwright processes"
    pkill -9 -f "playwright" 2>/dev/null
    echo "✅ Killed Playwright processes"
fi

# Kill Chromium processes spawned by Fara
CHROMIUM_PIDS=$(pgrep -f "chromium.*--remote-debugging" 2>/dev/null)
if [ -n "$CHROMIUM_PIDS" ]; then
    echo "📍 Found Chromium browser processes"
    pkill -9 -f "chromium.*--remote-debugging" 2>/dev/null
    echo "✅ Killed Chromium processes"
fi

echo ""
echo "🎉 Fara server stopped!"
echo ""

# Verify ports are free
echo "📋 Checking ports status:"
if lsof -i :8000 >/dev/null 2>&1; then
    echo "⚠️  Port 8000 still in use"
else
    echo "✅ Port 8000 is free"
fi

if lsof -i :5000 >/dev/null 2>&1; then
    echo "⚠️  Port 5000 still in use"
else
    echo "✅ Port 5000 is free"
fi
