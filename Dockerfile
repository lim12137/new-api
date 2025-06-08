FROM node:18-alpine AS builder

WORKDIR /build
COPY web/package.json web/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY ./web .
COPY ./VERSION .
RUN DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) pnpm run build

FROM golang:alpine AS builder2

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /build

ADD go.mod go.sum ./
RUN go mod download

COPY . .
COPY --from=builder /build/dist ./web/dist
RUN go build -ldflags "-s -w -X 'one-api/common.Version=$(cat VERSION)'" -o one-api

FROM python:3.9-alpine AS tokenizer-downloader

# 设置环境变量
ENV HUGGINGFACE_HUB_CACHE=/cache
ENV TRANSFORMERS_CACHE=/cache
ENV HF_HOME=/cache

# 安装必要的包
RUN pip install --no-cache-dir huggingface_hub transformers torch --index-url https://download.pytorch.org/whl/cpu

# 创建缓存目录
RUN mkdir -p /cache

# 复制预下载脚本
COPY docker/huggingface-tei/preload_tokenizers.py /preload_tokenizers.py

# 运行预下载脚本
RUN python /preload_tokenizers.py

FROM alpine

RUN apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates tzdata ffmpeg python3 py3-pip \
    && update-ca-certificates

# 复制预下载的解码器缓存
COPY --from=tokenizer-downloader /cache /data/cache

# 安装Python依赖用于运行时解码器管理
RUN pip3 install --no-cache-dir huggingface_hub transformers

# 复制解码器管理脚本
COPY docker/huggingface-tei/tokenizer_manager.py /usr/local/bin/tokenizer_manager.py
RUN chmod +x /usr/local/bin/tokenizer_manager.py

COPY --from=builder2 /build/one-api /
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/one-api"]
