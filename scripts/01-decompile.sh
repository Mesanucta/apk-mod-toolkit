#!/bin/bash
set -e

# APK 解包脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

log_info "=========================================="
log_info "步骤 1: APK 解包"
log_info "=========================================="

# 检查依赖
check_deps

# 验证原始 APK
log_info "验证原始 APK..."
validate_file "$ORIGINAL_APK" 1000000

# 清理旧的解包目录
if [[ -d "$DECOMPILED_DIR" ]]; then
    log_info "清理旧的解包目录..."
    rm -rf "$DECOMPILED_DIR"
fi

# 解包 APK
log_info "开始解包 APK..."
java -jar "$APKTOOL_JAR" d "$ORIGINAL_APK" -o "$DECOMPILED_DIR" -f

# 验证解包结果
log_info "验证解包结果..."

# 检查关键文件和目录
validate_file "$DECOMPILED_DIR/AndroidManifest.xml"
validate_dir "$DECOMPILED_DIR/smali"
validate_dir "$DECOMPILED_DIR/res"
validate_file "$DECOMPILED_DIR/apktool.yml"

# 检查 smali 文件数量
SMALI_COUNT=$(find "$DECOMPILED_DIR/smali" -name "*.smali" 2>/dev/null | wc -l)
log_info "Smali 文件数量: $SMALI_COUNT"

if [[ $SMALI_COUNT -lt 1000 ]]; then
    handle_error "Smali 文件数量过少，解包可能不完整"
fi

log_success "✓ APK 解包完成"
log_info "解包目录: $DECOMPILED_DIR"
