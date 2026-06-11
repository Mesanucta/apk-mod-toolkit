#!/bin/bash
set -e

# 一键执行所有步骤

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_info "=========================================="
log_info "APK 自动化修改工具"
log_info "=========================================="
echo ""

# 按顺序执行所有步骤
bash "$SCRIPT_DIR/01-decompile.sh"
echo ""

bash "$SCRIPT_DIR/02-modify.sh"
echo ""

bash "$SCRIPT_DIR/03-rebuild.sh"
echo ""

bash "$SCRIPT_DIR/04-sign.sh"
echo ""

bash "$SCRIPT_DIR/05-verify.sh"
echo ""

log_success "=========================================="
log_success "✓ 所有步骤完成！"
log_success "=========================================="
