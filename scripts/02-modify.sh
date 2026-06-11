#!/bin/bash
set -e

# APK 修改脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

log_info "=========================================="
log_info "步骤 2: 修改 APK 内容"
log_info "=========================================="

# 验证解包目录
validate_dir "$DECOMPILED_DIR"
validate_file "$MOD_CONFIG"

# 读取配置
log_info "读取修改配置..."
NEW_VERSION_NAME=$(grep '"new_version_name"' "$MOD_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
NEW_VERSION_CODE=$(grep '"new_version_code"' "$MOD_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
NEW_LAUNCHER_NAME=$(grep '"app_launcher_name"' "$MOD_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
NEW_APP_NAME=$(grep '"app_name"' "$MOD_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
DEBUGGABLE=$(grep '"debuggable"' "$MOD_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')

log_info "配置内容:"
log_info "  版本名称: $NEW_VERSION_NAME"
log_info "  版本号: $NEW_VERSION_CODE"
log_info "  启动器名称: $NEW_LAUNCHER_NAME"
log_info "  应用名称: $NEW_APP_NAME"
log_info "  调试模式: $DEBUGGABLE"

# 创建备份目录
BACKUP_DIR="$OUTPUT_DIR/backups"
mkdir -p "$BACKUP_DIR"

# 1. 修改 strings.xml
STRINGS_FILE="$DECOMPILED_DIR/res/values/strings.xml"
if [[ -f "$STRINGS_FILE" ]]; then
    log_info "修改应用名称 (strings.xml)..."
    cp "$STRINGS_FILE" "$BACKUP_DIR/strings.xml.bak"

    sed -i "s|<string name=\"app_launcher_name\">Notes</string>|<string name=\"app_launcher_name\">$NEW_LAUNCHER_NAME</string>|g" "$STRINGS_FILE"
    sed -i "s|<string name=\"app_name\">Fossify Notes</string>|<string name=\"app_name\">$NEW_APP_NAME</string>|g" "$STRINGS_FILE"

    log_success "✓ 应用名称修改完成"
else
    log_warning "strings.xml 不存在，跳过名称修改"
fi

# 2. 修改 apktool.yml
APKTOOL_YML="$DECOMPILED_DIR/apktool.yml"
if [[ -f "$APKTOOL_YML" ]]; then
    log_info "修改版本信息 (apktool.yml)..."
    cp "$APKTOOL_YML" "$BACKUP_DIR/apktool.yml.bak"

    sed -i "s/versionCode: '[0-9]*'/versionCode: '$NEW_VERSION_CODE'/g" "$APKTOOL_YML"
    sed -i "s/versionName: [0-9.]*/versionName: $NEW_VERSION_NAME/g" "$APKTOOL_YML"

    log_success "✓ 版本信息修改完成"
else
    log_warning "apktool.yml 不存在"
fi

# 3. 修改 AndroidManifest.xml（启用调试模式）
MANIFEST_FILE="$DECOMPILED_DIR/AndroidManifest.xml"
if [[ -f "$MANIFEST_FILE" && "$DEBUGGABLE" == "true" ]]; then
    log_info "启用调试模式 (AndroidManifest.xml)..."
    cp "$MANIFEST_FILE" "$BACKUP_DIR/AndroidManifest.xml.bak"

    # 检查是否已经有 debuggable 属性
    if grep -q "android:debuggable" "$MANIFEST_FILE"; then
        sed -i 's/android:debuggable="[^"]*"/android:debuggable="true"/g' "$MANIFEST_FILE"
    else
        sed -i 's/<application/<application android:debuggable="true"/g' "$MANIFEST_FILE"
    fi

    log_success "✓ 调试模式已启用"
fi

log_success "✓ APK 内容修改完成"
