#!/bin/bash
set -e

# APK 签名脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

log_info "=========================================="
log_info "步骤 4: APK 签名"
log_info "=========================================="

# 验证重打包的 APK
validate_file "$MODIFIED_APK"

# 步骤 1: 生成密钥库（如果不存在）
if [[ ! -f "$KEYSTORE_FILE" ]]; then
    log_info "生成调试密钥库..."
    keytool -genkey -v \
        -keystore "$KEYSTORE_FILE" \
        -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=APK Mod, OU=Dev, O=Local, L=Local, ST=Local, C=US" \
        -storepass "$KEYSTORE_PASS" \
        -keypass "$KEY_PASS"
    log_success "✓ 密钥库生成完成"
else
    log_info "使用现有密钥库: $KEYSTORE_FILE"
fi

# 步骤 2: 对齐 APK
log_info "对齐 APK..."
if [[ -f "$ALIGNED_APK" ]]; then
    rm -f "$ALIGNED_APK"
fi

zipalign -v -p 4 "$MODIFIED_APK" "$ALIGNED_APK"
log_success "✓ APK 对齐完成"

# 步骤 3: 签名 APK
log_info "签名 APK..."
if [[ -f "$SIGNED_APK" ]]; then
    rm -f "$SIGNED_APK"
fi

# 检查是否有 apksigner
if command -v apksigner &> /dev/null; then
    apksigner sign \
        --ks "$KEYSTORE_FILE" \
        --ks-key-alias "$KEYSTORE_ALIAS" \
        --ks-pass "pass:$KEYSTORE_PASS" \
        --key-pass "pass:$KEY_PASS" \
        --out "$SIGNED_APK" \
        "$ALIGNED_APK"
else
    # 使用 jarsigner 作为备选方案
    log_warning "apksigner 未找到，使用 jarsigner"
    cp "$ALIGNED_APK" "$SIGNED_APK"
    jarsigner -verbose \
        -sigalg SHA256withRSA \
        -digestalg SHA-256 \
        -keystore "$KEYSTORE_FILE" \
        -storepass "$KEYSTORE_PASS" \
        -keypass "$KEY_PASS" \
        "$SIGNED_APK" \
        "$KEYSTORE_ALIAS"
fi

log_success "✓ APK 签名完成"

# 验证签名
log_info "验证签名..."
if command -v apksigner &> /dev/null; then
    if apksigner verify "$SIGNED_APK" 2>&1 | grep -q "Verified"; then
        log_success "✓ 签名验证通过"
    else
        apksigner verify --verbose "$SIGNED_APK" || true
    fi
else
    if jarsigner -verify "$SIGNED_APK" 2>&1 | grep -q "jar verified"; then
        log_success "✓ 签名验证通过"
    else
        jarsigner -verify -verbose "$SIGNED_APK" || true
    fi
fi

log_info "最终 APK: $SIGNED_APK"
