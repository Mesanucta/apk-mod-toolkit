#!/bin/bash
set -e

# APK 重打包脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

log_info "=========================================="
log_info "步骤 3: 重打包 APK"
log_info "=========================================="

# 验证解包目录
validate_dir "$DECOMPILED_DIR"

# 删除旧的 APK
if [[ -f "$MODIFIED_APK" ]]; then
    log_info "删除旧的 APK..."
    rm -f "$MODIFIED_APK"
fi

# 重打包 APK
log_info "开始重打包 APK..."
java -jar "$APKTOOL_JAR" b "$DECOMPILED_DIR" -o "$MODIFIED_APK"

# 验证重打包结果
log_info "验证重打包结果..."
validate_file "$MODIFIED_APK" 5000000

# 获取文件大小
FILE_SIZE=$(du -h "$MODIFIED_APK" | cut -f1)
log_info "APK 大小: $FILE_SIZE"

# 验证 ZIP 格式
if ! unzip -t "$MODIFIED_APK" &> /dev/null; then
    handle_error "APK 文件格式无效"
fi

log_success "✓ APK 重打包完成"
log_info "输出文件: $MODIFIED_APK"
