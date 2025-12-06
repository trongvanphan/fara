# Hướng dẫn chạy FARA-7B với Magentic-UI

Hướng dẫn này sẽ giúp bạn thiết lập và chạy FARA-7B như một Computer Use Agent (CUA) thông qua Magentic-UI - giống như demo trên trang Microsoft Research.

## Tổng quan Kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                     Magentic-UI (Frontend)                   │
│                    http://localhost:8081                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Magentic-UI Backend                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Orchestrator│  │    Coder    │  │     File Surfer     │  │
│  │   (GPT-4o)  │  │   (GPT-4o)  │  │      (GPT-4o)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              Web Surfer (FARA-7B)                       ││
│  │         Kết nối đến OpenAI-compatible endpoint          ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              FARA-7B Server (VLLM/llama.cpp)                 │
│               OpenAI-compatible API                          │
│                  http://localhost:8000                       │
└─────────────────────────────────────────────────────────────┘
```

## Yêu cầu

### Phần cứng
- **Cho FARA-7B local**: GPU với ít nhất 16GB VRAM (NVIDIA RTX 3090/4090, A100, etc.)
- **Cho CPU inference**: Ít nhất 16GB RAM (chậm hơn nhiều)

### Phần mềm
- Python 3.10+
- Docker (cho Magentic-UI)
- OpenAI API key (cho Orchestrator, Coder, File Surfer)
- CUDA toolkit (nếu dùng GPU)

## Bước 1: Cài đặt Magentic-UI

```bash
# Tạo virtual environment mới
python3 -m venv magentic-ui-env
source magentic-ui-env/bin/activate

# Cài đặt Magentic-UI
pip install magentic-ui --upgrade

# Cài đặt playwright browsers
playwright install
```

## Bước 2: Khởi động FARA-7B Server

### Option A: Sử dụng VLLM (Recommended cho GPU)

```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara

# Khởi động FARA server
./start_fara_server.sh
```

### Option B: Sử dụng llama.cpp với GGUF model

```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara

# Nếu có llama.cpp server
./llama-server \
    -m model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --mmproj model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf \
    --port 8000 \
    --host 0.0.0.0
```

### Option C: Sử dụng Azure Foundry (Không cần GPU)

Nếu bạn không có GPU, có thể deploy FARA-7B trên Azure Foundry:
1. Truy cập: https://ai.azure.com/explore/models/Fara-7B
2. Deploy model và lấy endpoint URL + API key
3. Cập nhật `base_url` và `api_key` trong config file

## Bước 3: Cấu hình Magentic-UI để sử dụng FARA

Chạy Magentic-UI với config file đã tạo:

```bash
# Export OpenAI API key (cho Orchestrator, Coder, etc.)
export OPENAI_API_KEY="your-openai-api-key"

# Chạy Magentic-UI với FARA config
magentic-ui --port 8081 --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/fara_config.yaml
```

## Bước 4: Sử dụng Magentic-UI

1. Mở trình duyệt và truy cập: http://localhost:8081
2. Bạn sẽ thấy giao diện Magentic-UI
3. Nhập task muốn thực hiện, ví dụ:
   - "Search for the latest iPhone prices on Amazon"
   - "Find and summarize the top 3 news articles about AI"
   - "Book a flight from San Francisco to New York"

## Lưu ý quan trọng

### Về Safety và Critical Points
FARA-7B được train để dừng lại tại "Critical Points" - những điểm yêu cầu:
- Thông tin cá nhân của user
- Xác nhận trước khi thực hiện giao dịch
- Consent trước các hành động không thể đảo ngược

### Chạy trong Sandbox
Khuyến nghị chạy trong môi trường sandbox để tránh các hành động không mong muốn.

### Model Info cho FARA-7B
Khi cấu hình, cần set:
- `vision: true` - FARA là multimodal model
- `function_calling: true` - Hỗ trợ tool calling
- `json_output: true` - Có thể output JSON

## Troubleshooting

### FARA server không phản hồi
```bash
# Kiểm tra server status
curl http://localhost:8000/v1/models

# Kiểm tra logs
tail -f /path/to/fara/logs
```

### Magentic-UI không kết nối được FARA
- Đảm bảo FARA server đang chạy trên port 8000
- Kiểm tra `base_url` trong config đúng
- Thử restart cả FARA server và Magentic-UI

### Out of Memory
- Giảm batch size trong VLLM config
- Sử dụng quantized model (Q4 thay vì Q8)
- Sử dụng Azure Foundry hosting

## 🔑 Cách set OpenAI API Key

### Option 1: Environment Variable (Recommended)
```bash
export OPENAI_API_KEY="your-openai-api-key"
```

### Option 2: Trong config file
Edit `fara_config.yaml`:
```yaml
gpt4o_client: &gpt4o_client
  provider: OpenAIChatCompletionClient
  config:
    model: gpt-4o-2024-08-06
    api_key: "sk-your-actual-key-here"  # Set trực tiếp ở đây
```

---

## 🏠 Chạy 100% Local (Không cần OpenAI)

Nếu bạn muốn chạy hoàn toàn local mà **KHÔNG cần OpenAI API key**, sử dụng **Ollama**:

### Bước 1: Cài đặt Ollama
```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh

# Hoặc tải từ: https://ollama.com/download
```

### Bước 2: Pull model cho Ollama
```bash
# Khởi động Ollama
ollama serve

# Pull model (chọn 1 trong các model dưới)
ollama pull qwen2.5:32b    # Mạnh nhất, cần ~20GB RAM
ollama pull qwen2.5:7b     # Nhẹ hơn, cần ~8GB RAM  
ollama pull llama3.1:8b    # Alternative
ollama pull mistral:7b     # Nhẹ nhất
```

### Bước 3: Chạy local mode
```bash
./start_local.sh
```

Script này sẽ:
- ✅ Khởi động Ollama
- ✅ Khởi động FARA-7B server
- ✅ Khởi động Magentic-UI với config local
- ✅ KHÔNG cần OpenAI API key!

---

## Files trong thư mục này

| File | Mô tả |
|------|-------|
| **Config files** | |
| `fara_config.yaml` | FARA + GPT-4o (cần OpenAI key) |
| `local_only_config.yaml` | FARA + Ollama (100% local) |
| `fara_only_config.yaml` | FARA cho tất cả agents |
| **Scripts** | |
| `start_all.sh` | Khởi động với OpenAI |
| `start_local.sh` | Khởi động với Ollama (100% local) |
| `start_fara_only.sh` | Khởi động chỉ với FARA (đơn giản nhất) |
| `stop_all.sh` | Dừng toàn bộ hệ thống |
| `install_magentic_ui.sh` | Cài đặt Magentic-UI |

### So sánh các mode

| Mode | Script | Yêu cầu | Ưu điểm |
|------|--------|---------|---------|
| **FARA + OpenAI** | `start_all.sh` | OpenAI API key | Tốt nhất cho coding/planning |
| **FARA + Ollama** | `start_local.sh` | Ollama + RAM | Cân bằng, 100% local |
| **FARA Only** | `start_fara_only.sh` | Chỉ FARA server | Đơn giản nhất, ít tài nguyên |

## Tham khảo

- [FARA-7B GitHub](https://github.com/microsoft/fara)
- [Magentic-UI GitHub](https://github.com/microsoft/Magentic-UI)
- [FARA-7B Blog Post](https://www.microsoft.com/en-us/research/blog/fara-7b-an-efficient-agentic-model-for-computer-use/)
- [FARA-7B on HuggingFace](https://huggingface.co/microsoft/Fara-7b)
