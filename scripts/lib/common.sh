#!/bin/bash

# 公共函数库 - 提供日志、错误处理等功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 错误处理
handle_error() {
    log_error "$1"
    exit 1
}

# 文件验证
validate_file() {
    local file="$1"
    local min_size="${2:-0}"

    if [[ ! -f "$file" ]]; then
        handle_error "文件不存在: $file"
    fi

    local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    if [[ $size -lt $min_size ]]; then
        handle_error "文件大小不符合要求: $file (${size} bytes < ${min_size} bytes)"
    fi
}

# 目录验证
validate_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        handle_error "目录不存在: $dir"
    fi
}

# 依赖检查
check_java() {
    if ! command -v java &> /dev/null; then
        handle_error "Java 未安装或未在 PATH 中"
    fi
    log_info "Java 版本: $(java -version 2>&1 | head -n 1)"
}

check_deps() {
    check_java
}

# 清理函数
cleanup_temp() {
    local temp_dir="$1"
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        log_info "清理临时文件: $temp_dir"
        rm -rf "$temp_dir"
    fi
}
