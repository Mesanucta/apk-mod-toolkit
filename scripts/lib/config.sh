#!/bin/bash

# 配置管理 - 定义所有路径和配置变量

# 获取项目根目录（相对于此脚本的位置）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 工具路径
APKTOOL_JAR="$PROJECT_ROOT/apktool_2.11.1.jar"

# 文件路径 - 支持通过环境变量指定 APK
ORIGINAL_APK="${APK_FILE:-$PROJECT_ROOT/notes-13-foss-release.apk}"

# 输出目录
OUTPUT_DIR="$PROJECT_ROOT/output"
DECOMPILED_DIR="$OUTPUT_DIR/decompiled"
MODIFIED_APK="$OUTPUT_DIR/modified.apk"
ALIGNED_APK="$OUTPUT_DIR/aligned.apk"
SIGNED_APK="$OUTPUT_DIR/signed.apk"
LOG_DIR="$OUTPUT_DIR/logs"

# 配置文件
MOD_CONFIG="$PROJECT_ROOT/mods/config.json"

# 密钥库
KEYSTORE_DIR="$PROJECT_ROOT/keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/debug.keystore"
KEYSTORE_ALIAS="apk-mod-key"
KEYSTORE_PASS="android"
KEY_PASS="android"

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR" "$LOG_DIR" "$KEYSTORE_DIR"
