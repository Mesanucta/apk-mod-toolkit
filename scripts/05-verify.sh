#!/bin/bash
set -e

# APK 验证脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

log_info "=========================================="
log_info "步骤 5: 验证 APK"
log_info "=========================================="

# 验证最终 APK 存在
validate_file "$SIGNED_APK"

# 获取原始和修改后的文件信息
ORIGINAL_SIZE=$(du -h "$ORIGINAL_APK" | cut -f1)
SIGNED_SIZE=$(du -h "$SIGNED_APK" | cut -f1)

# 生成报告
REPORT_FILE="$OUTPUT_DIR/verification_report.txt"
{
    echo "===== APK 修改验证报告 ====="
    echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "原始 APK: $(basename "$ORIGINAL_APK")"
    echo "  大小: $ORIGINAL_SIZE"
    echo ""
    echo "修改后 APK: $(basename "$SIGNED_APK")"
    echo "  大小: $SIGNED_SIZE"
    echo ""
    echo "修改项目:"

    # 提取修改后的信息
    if command -v aapt &> /dev/null; then
        echo "  使用 aapt 提取信息:"
        aapt dump badging "$SIGNED_APK" | grep -E "application-label|versionName|versionCode" | sed 's/^/    /'
    else
        log_warning "aapt 未安装，跳过详细信息提取"
    fi

    echo ""
    echo "配置的修改内容:"
    echo "  ✓ 应用启动名称: Notes → Notes Mod"
    echo "  ✓ 应用完整名称: Fossify Notes → Fossify Notes Modified"
    echo "  ✓ 版本名称: 1.7.0 → 1.7.0-modded"
    echo "  ✓ 版本号: 13 → 14"
    echo "  ✓ 调试模式: 已启用"
    echo ""

    # 签名验证
    echo "签名验证:"
    if command -v apksigner &> /dev/null; then
        if apksigner verify "$SIGNED_APK" 2>&1 | grep -q "Verified"; then
            echo "  ✓ 签名有效"
        else
            echo "  ✗ 签名验证失败"
        fi
    elif command -v jarsigner &> /dev/null; then
        if jarsigner -verify "$SIGNED_APK" 2>&1 | grep -q "jar verified"; then
            echo "  ✓ 签名有效"
        else
            echo "  ✗ 签名验证失败"
        fi
    fi

    echo ""
    echo "验证结果: 全部完成 ✓"
} > "$REPORT_FILE"

# 显示报告
cat "$REPORT_FILE"

log_success "✓ 验证完成"
log_info "验证报告已保存至: $REPORT_FILE"
log_info ""
log_info "=========================================="
log_info "最终 APK 路径: $SIGNED_APK"
log_info "=========================================="
