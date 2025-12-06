# 🏠 Hướng dẫn chạy FARA + Magentic-UI 100% LOCAL

Hướng dẫn chi tiết để chạy **hoàn toàn local** mà **KHÔNG cần OpenAI API key**.

## 📋 Tổng quan - Hai chế độ chạy

### 🚀 Chế độ 1: FARA-ONLY (Đơn giản nhất!)

Chỉ cần **1 model duy nhất** - FARA-7B cho TẤT CẢ agents!

| Thành phần | Model | Port | Mục đích |
|------------|-------|------|----------|
| **FARA-7B** | Fara-7B (GGUF) | 8000 | **TẤT CẢ agents** (Web Surfer, Coder, Orchestrator,...) |
| **Magentic-UI** | - | 8081 | Frontend UI |

**Ưu điểm:**
- ✅ Không cần Ollama
- ✅ Chỉ 1 model, dễ quản lý
- ✅ FARA có vision + function calling
- ✅ RAM/VRAM tiết kiệm hơn

**Nhược điểm:**
- ⚠️ FARA được optimize cho web browsing, coding có thể không bằng model chuyên

### 🔧 Chế độ 2: FARA + Ollama (Tối ưu performance)

| Thành phần | Model | Port | Mục đích |
|------------|-------|------|----------|
| **FARA-7B** | Fara-7B (GGUF) | 8000 | Web Surfer - Browse web |
| **Ollama** | qwen2.5:7b hoặc 32b | 11434 | Orchestrator, Coder, File Surfer |
| **Magentic-UI** | - | 8081 | Frontend UI |

**Ưu điểm:**
- ✅ Mỗi model làm việc tối ưu của mình
- ✅ Qwen2.5 mạnh cho coding tasks

**Nhược điểm:**
- ⚠️ Cần cài thêm Ollama
- ⚠️ Tốn thêm RAM cho 2 models

## 🖥️ Yêu cầu hệ thống

### Cho FARA-ONLY mode
- **RAM**: 16GB
- **VRAM** (GPU): 8GB (nếu có)
- **Disk**: 10GB free

### Cho FARA + Ollama mode
- **RAM**: 24GB+ (chạy 2 models)
- **VRAM** (GPU): 12GB+ (nếu có)
- **Disk**: 20GB free

---

## ⭐ FARA-ONLY Mode (Khuyến nghị cho máy yếu)

### Quick Start

**Terminal 1: FARA Server**
```bash
source /Users/trongpv6/Documents/GitHub/poc-code/fara/.venv/bin/activate && \
cd /Users/trongpv6/Documents/GitHub/poc-code/fara && \
python -m llama_cpp.server \
    --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --clip_model_path model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf \
    --port 8000 --host 0.0.0.0 --n_ctx 4096 --chat_format chatml
```

**Terminal 2: Magentic-UI (với Docker)**
```bash
export DOCKER_HOST=unix:///Users/trongpv6/.docker/run/docker.sock && \
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate && \
magentic-ui --port 8081 --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/fara_only_config.yaml
```

**Hoặc dùng script:**
```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup
./start_fara_only.sh
```

**Truy cập:** http://localhost:8081

---

## 🔧 FARA + Ollama Mode (Tối ưu cho máy mạnh)

## 🚀 Cài đặt từng bước

### Bước 1: Cài đặt Ollama

```bash
# macOS
brew install ollama

# Linux  
curl -fsSL https://ollama.com/install.sh | sh

# Windows: Tải từ https://ollama.com/download
```

### Bước 2: Pull model Ollama

```bash
# Khởi động Ollama service
ollama serve

# Mở terminal mới, pull model (chọn 1):

# Option A: Nhẹ nhất - Cần ~5GB RAM
ollama pull qwen2.5:7b

# Option B: Mạnh hơn - Cần ~20GB RAM  
ollama pull qwen2.5:32b

# Option C: Alternative
ollama pull llama3.1:8b
ollama pull mistral:7b

# (Optional) Model có vision - cho File Surfer
ollama pull llava:7b
```

### Bước 3: Cài đặt FARA Server

```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara

# Tạo virtual environment
python3 -m venv venv
source venv/bin/activate

# Cài đặt dependencies
pip install -r requirements.txt

# Hoặc cài llama-cpp-python cho GGUF model
pip install llama-cpp-python[server]
```

### Bước 4: Cài đặt Magentic-UI

```bash
# Tạo venv mới
python3 -m venv magentic-env
source magentic-env/bin/activate

# Cài Magentic-UI
pip install magentic-ui

# Cài playwright browsers
playwright install
```

---

## ⚙️ Cấu hình

### Config file: `local_only_config.yaml`

```yaml
# Magentic-UI Configuration - 100% LOCAL

# FARA-7B cho Web Surfer (port 8000)
fara_client: &fara_client
  provider: OpenAIChatCompletionClient
  config:
    model: Fara-7B
    api_key: "not-needed"
    base_url: "http://localhost:8000/v1"
    max_retries: 10
    model_info:
      vision: true
      function_calling: true
      json_output: true
      family: "unknown"
      structured_output: false
      multiple_system_messages: false

# Ollama cho các agents khác (port 11434)
ollama_client: &ollama_client
  provider: OpenAIChatCompletionClient
  config:
    model: "qwen2.5:7b"  # Hoặc: qwen2.5:32b, llama3.1:8b
    api_key: "ollama"
    base_url: "http://localhost:11434/v1"
    max_retries: 5
    model_info:
      vision: false
      function_calling: true
      json_output: true
      family: "unknown"

# Phân bổ clients
orchestrator_client: *ollama_client
coder_client: *ollama_client
web_surfer_client: *fara_client
file_surfer_client: *ollama_client
action_guard_client: *ollama_client
plan_learning_client: *ollama_client
```

---

## 🎬 Khởi động

### Option 1: Sử dụng script tự động

```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup

# Khởi động tất cả
./start_local.sh

# Dừng tất cả
./stop_all.sh
```

### Option 2: Khởi động thủ công

**Terminal 1: Ollama**
```bash
ollama serve
# Hoặc nếu đã cài qua brew:
# brew services start ollama
```

**Terminal 2: FARA Server**
```bash
cd /Users/trongpv6/Documents/GitHub/poc-code/fara

# Kích hoạt venv của FARA
source .venv/bin/activate

# Chạy với llama-cpp-python
python -m llama_cpp.server \
    --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --clip_model_path model_checkpoints/Qwen2.5-VL-7B-Instruct-mmproj-f16.gguf \
    --port 8000 \
    --host 0.0.0.0 \
    --n_ctx 4096 \
    --chat_format chatml
```

**Terminal 3: Magentic-UI**
```bash
# Kích hoạt venv của Magentic-UI
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate

# Chạy KHÔNG Docker (không có live browser view)
magentic-ui \
    --port 8081 \
    --run-without-docker \
    --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/local_only_config.yaml
```

---

## 🐳 Chạy với Docker (Live Browser View)

Để có **live browser view** (xem AI browse web trong thời gian thực), cần chạy với Docker.

### Bước 1: Khởi động Docker Desktop

```bash
# macOS
open -a Docker

# Đợi Docker khởi động xong (khoảng 20-30 giây)
sleep 20
docker ps  # Kiểm tra Docker đã sẵn sàng
```

### Bước 2: Chạy Magentic-UI với Docker

⚠️ **Lưu ý quan trọng cho macOS**: Docker socket nằm ở vị trí khác, cần set `DOCKER_HOST`:

```bash
# Kích hoạt venv
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate

# Set Docker socket cho macOS (BẮT BUỘC)
export DOCKER_HOST=unix:///Users/trongpv6/.docker/run/docker.sock

# Chạy Magentic-UI với Docker
magentic-ui \
    --port 8081 \
    --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/local_only_config.yaml
```

### Một dòng lệnh (copy-paste):

```bash
export DOCKER_HOST=unix:///Users/trongpv6/.docker/run/docker.sock && \
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate && \
magentic-ui --port 8081 --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/local_only_config.yaml
```

### So sánh: Với Docker vs Không Docker

| Feature | Không Docker | Với Docker |
|---------|--------------|------------|
| Live browser view | ❌ Không có | ✅ Có |
| Code manipulation | ❌ Bị disable | ✅ Đầy đủ |
| File manipulation | ❌ Bị disable | ✅ Đầy đủ |
| Cài đặt | Đơn giản | Cần Docker Desktop |
| Tài nguyên | Nhẹ hơn | Nặng hơn |

---

## 🌐 Truy cập

Sau khi khởi động xong, mở trình duyệt:

**http://localhost:8081**

---

## 🔧 Kiểm tra services

```bash
# Check Ollama
curl http://localhost:11434/api/tags
ollama list

# Check FARA server
curl http://localhost:8000/v1/models

# Check Magentic-UI
curl http://localhost:8081
```

---

## 📊 So sánh các model Ollama

| Model | RAM cần | Tốc độ | Chất lượng | Ghi chú |
|-------|---------|--------|------------|---------|
| `qwen2.5:7b` | ~5GB | Nhanh | Tốt | **Khuyến nghị cho máy yếu** |
| `qwen2.5:14b` | ~10GB | Trung bình | Rất tốt | Cân bằng |
| `qwen2.5:32b` | ~20GB | Chậm | Xuất sắc | **Khuyến nghị cho máy mạnh** |
| `llama3.1:8b` | ~5GB | Nhanh | Tốt | Alternative |
| `mistral:7b` | ~5GB | Rất nhanh | Khá | Nhẹ nhất |
| `codellama:7b` | ~5GB | Nhanh | Tốt cho code | Chuyên code |

---

## ⚠️ Troubleshooting

### 1. Ollama không chạy

```bash
# Kiểm tra process
ps aux | grep ollama

# Restart Ollama
pkill ollama
ollama serve

# macOS với brew
brew services restart ollama
```

### 2. FARA server lỗi CUDA

```bash
# Chạy với CPU only
CMAKE_ARGS="-DLLAMA_CUBLAS=off" pip install llama-cpp-python --force-reinstall

# Hoặc giảm context
python -m llama_cpp.server \
    --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --n_ctx 2048 \  # Giảm từ 4096
    --n_gpu_layers 0  # CPU only
```

### 3. Out of Memory

```bash
# Dùng model nhỏ hơn
ollama pull qwen2.5:3b

# Hoặc dùng quantized thấp hơn (Q4 thay vì Q8)
# Download Q4 version từ HuggingFace
```

### 4. Magentic-UI không kết nối được

```bash
# Kiểm tra config path
cat /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/local_only_config.yaml

# Kiểm tra cả 2 services
curl http://localhost:8000/v1/models  # FARA
curl http://localhost:11434/api/tags  # Ollama
```

---

## 🎯 Tips hiệu năng

### Cho máy yếu (16GB RAM, không GPU)

```yaml
# Dùng model nhỏ
ollama_client:
  config:
    model: "qwen2.5:3b"  # Hoặc mistral:7b
```

### Cho máy mạnh (32GB+ RAM, GPU 16GB+)

```yaml
# Dùng model lớn
ollama_client:
  config:
    model: "qwen2.5:32b"
```

### Tối ưu FARA cho GPU

```bash
# Dùng nhiều GPU layers hơn
python -m llama_cpp.server \
    --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --n_gpu_layers 35 \  # Tăng số layers trên GPU
    --n_ctx 8192 \       # Tăng context
    --n_batch 512        # Tăng batch size
```

---

## 📚 Tham khảo

- [Ollama Documentation](https://ollama.com/)
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python)
- [FARA-7B on HuggingFace](https://huggingface.co/microsoft/Fara-7b)
- [Magentic-UI GitHub](https://github.com/microsoft/Magentic-UI)

---

## ✅ Checklist trước khi chạy

- [ ] Ollama đã cài và chạy (`ollama serve`)
- [ ] Đã pull model (`ollama pull qwen2.5:7b`)
- [ ] FARA model đã download (`model_checkpoints/microsoft_Fara-7B-Q8_0.gguf`)
- [ ] Magentic-UI đã cài (`pip install magentic-ui`)
- [ ] Playwright đã cài (`playwright install`)
- [ ] Docker Desktop đã cài và chạy (nếu muốn live browser view)

---

## 📂 Cấu trúc Virtual Environments

Dự án sử dụng **2 virtual environments riêng biệt**:

| Thành phần | Venv Path | Mục đích |
|------------|-----------|----------|
| **FARA Server** | `/poc-code/fara/.venv/` | Chạy llama-cpp-python server |
| **Magentic-UI** | `/poc-code/magentic-ui-custom/venv/` | Chạy Magentic-UI frontend |

### Kích hoạt đúng venv:

```bash
# Cho FARA Server
source /Users/trongpv6/Documents/GitHub/poc-code/fara/.venv/bin/activate

# Cho Magentic-UI
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate
```

### Tại sao cần 2 venv?

1. **Tránh xung đột dependencies**: FARA và Magentic-UI có thể cần các version khác nhau của cùng một package
2. **Dễ quản lý**: Mỗi project có dependencies riêng
3. **Dễ debug**: Khi có lỗi, biết chính xác project nào gây ra

---

## 🍎 Lưu ý quan trọng cho macOS

### 1. Docker Socket

Docker Desktop trên macOS đặt socket ở vị trí khác:

```bash
# Vị trí Docker socket trên macOS
/Users/<username>/.docker/run/docker.sock

# KHÔNG phải vị trí thông thường
# /var/run/docker.sock  ← Không tồn tại trên macOS
```

**Luôn set DOCKER_HOST trước khi chạy Magentic-UI:**

```bash
export DOCKER_HOST=unix:///Users/trongpv6/.docker/run/docker.sock
```

### 2. Python Environment

macOS mới (Sonoma+) không cho phép cài packages vào system Python:

```bash
# Lỗi này sẽ xuất hiện nếu cài trực tiếp:
# error: externally-managed-environment

# Giải pháp: Luôn dùng virtual environment
python3 -m venv myenv
source myenv/bin/activate
pip install <package>
```

### 3. Kiểm tra Docker đang chạy

```bash
# Cách 1: Kiểm tra docker command
docker ps

# Cách 2: Kiểm tra Docker socket
ls -la ~/.docker/run/docker.sock

# Cách 3: Kiểm tra Docker version
docker version
```

---

## 🛑 Dừng tất cả services

```bash
# Dừng Magentic-UI
pkill -f "magentic-ui"

# Dừng FARA Server
pkill -f "llama_cpp.server"

# Dừng Ollama
pkill ollama
# Hoặc nếu dùng brew:
brew services stop ollama

# Dừng Docker containers (nếu có)
docker stop $(docker ps -q)
```

---

## 🔄 Quick Start (Copy-Paste)

### Terminal 1: Ollama
```bash
ollama serve
```

### Terminal 2: FARA Server
```bash
source /Users/trongpv6/Documents/GitHub/poc-code/fara/.venv/bin/activate && \
cd /Users/trongpv6/Documents/GitHub/poc-code/fara && \
python -m llama_cpp.server \
    --model model_checkpoints/microsoft_Fara-7B-Q8_0.gguf \
    --port 8000 --host 0.0.0.0 --n_ctx 4096 --chat_format chatml
```

### Terminal 3: Magentic-UI (với Docker)
```bash
export DOCKER_HOST=unix:///Users/trongpv6/.docker/run/docker.sock && \
source /Users/trongpv6/Documents/GitHub/poc-code/magentic-ui-custom/venv/bin/activate && \
magentic-ui --port 8081 --config /Users/trongpv6/Documents/GitHub/poc-code/fara/magentic_ui_setup/local_only_config.yaml
```

### Truy cập: http://localhost:8081
