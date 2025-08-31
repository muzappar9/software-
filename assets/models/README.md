# Gemma 270M模型下载指南

## 📥 如何获取真实的Gemma 3 270M GGUF模型

### 方法1：从HuggingFace下载
```bash
# 使用官方链接下载（需要替换为真实URL）
curl -L "https://huggingface.co/lmstudio-community/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_0.gguf" -o "gemma-3-270m-instruct-q4_0.gguf"
```

### 方法2：通过LM Studio
1. 安装LM Studio
2. 搜索 "gemma 270m gguf"
3. 下载后复制到此目录

### 方法3：通过Ollama
```bash
ollama pull gemma:2b
# 然后找到模型文件位置并复制
```

## 📋 文件要求
- 文件名：`gemma-3-270m-instruct-q4_0.gguf`
- 大小：约100-200MB
- 格式：GGUF (llama.cpp兼容)

## ⚠️ 注意
- 模型文件较大，建议使用稳定网络下载
- 下载后app首启会自动拷贝到沙盒目录
- CI构建时GitHub Actions会自动下载（如果设置了MODEL_URL secret）