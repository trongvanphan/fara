#!/bin/bash
# Script để chạy Fara-7B GGUF server với llama-cpp-python
# Sử dụng Metal acceleration trên Mac M1

cd /Users/trongpv6/Documents/GitHub/poc-code/fara
source .venv/bin/activate

MODEL_PATH="model_checkpoints/microsoft_Fara-7B-Q8_0.gguf"
CLIP_PATH="model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf"
PORT=8000

echo "🚀 Starting Fara-7B server on port $PORT..."
echo "📁 Model: $MODEL_PATH"
echo "📸 CLIP: $CLIP_PATH"
echo "⚡ Using Metal GPU acceleration"
echo ""

python -m llama_cpp.server \
    --model "$MODEL_PATH" \
    --clip_model_path "$CLIP_PATH" \
    --host 0.0.0.0 \
    --port $PORT \
    --n_gpu_layers -1 \
    --n_ctx 4096 \
    --chat_format qwen2.5-vl \
    --verbose
