# Fara-7B Usage Guide (MacBook M1 Pro)

## 📖 Fara là gì?

**Fara-7B** là Computer Use Agent (CUA) của Microsoft, cho phép AI điều khiển browser tự động:
- Nhìn screenshot của trang web
- Click, gõ chữ, scroll, navigate
- Thực hiện các task phức tạp trên web

**Quan trọng:** Fara-7B là model đã được **fine-tuned** từ Qwen2.5-VL-7B với dữ liệu computer use. 
Model base Qwen2.5-VL chỉ là VLM thông thường, không có khả năng output `<tool_call>` actions như Fara.

---

## 🚀 Quick Start (5 phút)

### Bước 1: Khởi động Fara Server (llama-cpp-python)
```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara
source .venv/bin/activate

# Khởi động server với Metal GPU acceleration
.venv/bin/python -m llama_cpp.server \
  --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
  --clip_model_path model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf \
  --host 0.0.0.0 --port 8000 \
  --n_gpu_layers -1 --n_ctx 4096 \
  --chat_format qwen2.5-vl

# Hoặc dùng script:
./start_fara_server.sh
```

### Bước 2: Mở terminal mới và chạy Agent
```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara
source .venv/bin/activate

python test_fara_agent.py \
  --task "Tìm kiếm 'hello world' trên Bing" \
  --start_page "https://www.bing.com" \
  --endpoint_config endpoint_configs/fara_local_config.json \
  --headful \
  --save_screenshots \
  --downloads_folder outputs \
  --max_rounds 10
```

---

## 📋 Tất cả Command Options

| Option | Mô tả | Ví dụ |
|--------|-------|-------|
| `--task` | **Bắt buộc.** Task cần thực hiện | `--task "Book a flight to Paris"` |
| `--start_page` | URL bắt đầu | `--start_page "https://google.com"` |
| `--endpoint_config` | Config file cho model | `--endpoint_config endpoint_configs/fara_local_config.json` |
| `--headful` | Hiển thị browser (mặc định ẩn) | `--headful` |
| `--save_screenshots` | Lưu screenshot mỗi bước | `--save_screenshots` |
| `--downloads_folder` | Thư mục lưu files | `--downloads_folder outputs` |
| `--max_rounds` | Số bước tối đa (mặc định 100) | `--max_rounds 20` |
| `--browserbase` | Dùng BrowserBase cloud | `--browserbase` |

---

## 🎯 Các ví dụ Task

### Tìm kiếm đơn giản
```bash
python test_fara_agent.py \
  --task "Search for 'latest AI news'" \
  --start_page "https://www.bing.com" \
  --endpoint_config endpoint_configs/fara_local_config.json \
  --headful --max_rounds 5
```

### Điền form
```bash
python test_fara_agent.py \
  --task "Go to the contact form and fill in: Name=John, Email=john@test.com" \
  --start_page "https://example.com/contact" \
  --endpoint_config endpoint_configs/fara_local_config.json \
  --headful --max_rounds 15
```

### Research task
```bash
python test_fara_agent.py \
  --task "Find the population of Vietnam and take a screenshot" \
  --start_page "https://www.google.com" \
  --endpoint_config endpoint_configs/fara_local_config.json \
  --headful --save_screenshots --downloads_folder outputs --max_rounds 10
```

### Chạy headless (không hiện browser)
```bash
python test_fara_agent.py \
  --task "Search for Python tutorials" \
  --start_page "https://www.bing.com" \
  --endpoint_config endpoint_configs/fara_local_config.json \
  --max_rounds 10
```

---

## ⚙️ Endpoint Configs

### llama-cpp-python (Local - KHUYÊN DÙNG)
File: `endpoint_configs/fara_local_config.json`
```json
{
    "model": "Fara-7B",
    "base_url": "http://localhost:8000/v1",
    "api_key": "not-needed"
}
```

**Yêu cầu:** Phải khởi động server trước khi chạy agent!

### Ollama (Fallback - không khuyên dùng)
File: `endpoint_configs/ollama_config.json`
```json
{
    "model": "qwen2.5vl:7b",
    "base_url": "http://localhost:11434/v1",
    "api_key": "ollama"
}
```
⚠️ **Lưu ý:** Ollama dùng Qwen2.5-VL base, không phải Fara fine-tuned. Có thể không output đúng format `<tool_call>`.

### Nếu dùng OpenAI API (ví dụ GPT-4V)
Tạo file `endpoint_configs/openai_config.json`:
```json
{
    "model": "gpt-4-vision-preview",
    "base_url": "https://api.openai.com/v1",
    "api_key": "sk-your-api-key"
}
```

### Nếu dùng Azure OpenAI
File: `endpoint_configs/azure_foundry_config.json`

---

## 🔧 Troubleshooting

### Lỗi "Xvfb not found"
→ Đã fix! File `browser_bb.py` đã được patch để skip Xvfb trên macOS.

### Lỗi Ollama không chạy
```bash
# Kiểm tra
curl http://localhost:11434/api/version

# Restart Ollama
killall ollama
ollama serve
```

### Lỗi model không có
```bash
# Pull model
ollama pull qwen2.5vl:7b

# Kiểm tra models đã có
ollama list
```

### Browser bị crash
- Giảm `--max_rounds` 
- Thêm delay bằng cách chạy lại

---

## 📁 Cấu trúc thư mục

```
fara/
├── .venv/                      # Python virtual environment
├── endpoint_configs/
│   ├── fara_local_config.json  # Config cho llama-cpp-python (KHUYÊN DÙNG)
│   ├── ollama_config.json      # Config cho Ollama (fallback)
│   ├── vllm_config.json        # Config cho vLLM
│   └── azure_foundry_config.json
├── model_checkpoints/
│   ├── microsoft_Fara-7B-Q8_0.gguf           # Fara model (7.5GB)
│   └── Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf # CLIP vision encoder (1.35GB)
├── outputs/                    # Screenshots và downloads
├── src/fara/                   # Source code
├── test_fara_agent.py          # Script chính để chạy
├── start_fara_server.sh        # Script khởi động server
└── USAGE_GUIDE.md              # File này
```

---

## ❓ FAQ

### Q: Tại sao dùng llama-cpp-python thay vì Ollama?

**A:** 
- **llama-cpp-python**: Load trực tiếp `microsoft_Fara-7B-Q8_0.gguf` - đây là model Fara đã fine-tuned
- **Ollama**: Dùng `qwen2.5vl:7b` - đây là model base, KHÔNG phải Fara fine-tuned

Fara được fine-tuned đặc biệt để output `<tool_call>` actions (click, type, scroll...). Model base không có khả năng này.

### Q: Khác biệt giữa Qwen2.5-VL và Fara-7B?

| | Qwen2.5-VL-7B (Base) | Fara-7B (Fine-tuned) |
|---|---------------|---------|
| Nguồn | Alibaba Qwen | Microsoft fine-tuned |
| Khả năng | General VLM (mô tả ảnh) | Computer Use Agent |
| Output | Text thông thường | `<tool_call>{"name": "click", ...}</tool_call>` |
| Dùng cho | Vision tasks tổng quát | Browser automation |

### Q: Tốn bao nhiêu RAM?

- Fara Model: ~8GB
- CLIP mmproj: ~1.5GB
- Browser: ~1-2GB
- **Tổng: ~12GB** (M1 Pro 32GB đủ dùng)

### Q: Làm sao biết server đang chạy?

```bash
curl http://localhost:8000/v1/models
```

Nếu server chạy, sẽ trả về JSON với thông tin model.

---

## 🔄 Commands tắt nhanh

```bash
# Alias để chạy nhanh (thêm vào ~/.zshrc)
alias fara-activate='cd /Users/trongpv6/Documents/GitHub/poc-code/fara && source .venv/bin/activate'

alias fara-server='.venv/bin/python -m llama_cpp.server --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf --clip_model_path model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf --host 0.0.0.0 --port 8000 --n_gpu_layers -1 --n_ctx 4096 --chat_format qwen2.5-vl'

alias fara-search='python test_fara_agent.py --start_page "https://www.bing.com" --endpoint_config endpoint_configs/fara_local_config.json --headful --max_rounds 10 --task'

# Sử dụng:
# Terminal 1:
fara-activate
fara-server

# Terminal 2:
fara-activate
fara-search "Find weather in Hanoi"
```

---

## 🛠️ Server Commands

### Khởi động server
```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara
source .venv/bin/activate

.venv/bin/python -m llama_cpp.server \
  --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
  --clip_model_path model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf \
  --host 0.0.0.0 --port 8000 \
  --n_gpu_layers -1 --n_ctx 4096 \
  --chat_format qwen2.5-vl
```

### Kiểm tra server
```bash
# Xem models
curl http://localhost:8000/v1/models

# Test chat (text only)
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Fara-7B", "messages": [{"role": "user", "content": "Hello"}]}'
```

### Dừng server
```bash
# Tìm process
lsof -i :8000

# Kill process
kill -9 <PID>
```

---

## 📞 Support

- GitHub: https://github.com/microsoft/Fara
- Model: https://huggingface.co/microsoft/Fara-7B
- GGUF: https://huggingface.co/Mungert/Fara-7B-GGUF
