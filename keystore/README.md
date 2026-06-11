# 密钥库说明

## 关于调试密钥库

本目录用于存储 APK 签名所需的密钥库文件。

### 自动生成

当你首次运行 `04-sign.sh` 脚本时，会自动生成一个调试密钥库：

- **文件名**: `debug.keystore`
- **别名**: `apk-mod-key`
- **密码**: `android`（密钥库密码和密钥密码相同）
- **算法**: RSA 2048 位
- **有效期**: 10000 天

### 重要提示

⚠️ **安全警告**：
- 此密钥库仅用于开发和测试目的
- **不要用于生产环境或正式发布**
- **不要提交到公共仓库**（已在 .gitignore 中忽略）

### 密钥库管理

**查看密钥信息：**
```bash
keytool -list -v -keystore debug.keystore -storepass android
```

**重新生成密钥库：**
如果需要重新生成，只需删除 `debug.keystore` 文件，脚本会自动创建新的。

```bash
rm debug.keystore
bash ../scripts/04-sign.sh
```

**备份密钥库：**
如果你想在其他设备上使用相同的签名，可以备份此文件到安全位置。

### 生产环境签名

如果需要正式发布应用，请：
1. 生成生产密钥库（更强的密码和保护）
2. 妥善保管密钥库文件和密码
3. 修改 `scripts/lib/config.sh` 中的密钥库路径

**生成生产密钥库示例：**
```bash
keytool -genkey -v \
  -keystore release.keystore \
  -alias release-key \
  -keyalg RSA \
  -keysize 4096 \
  -validity 25000 \
  -storepass <your-strong-password> \
  -keypass <your-strong-password>
```

## 技术细节

### 签名类型

本项目支持两种签名工具：

1. **apksigner**（推荐）- Android SDK 提供的现代签名工具
2. **jarsigner** - Java 自带的签名工具（备用方案）

脚本会自动检测并使用可用的工具。

### 签名方案

- 支持 APK Signature Scheme v1 (JAR signing)
- 支持 APK Signature Scheme v2（如果使用 apksigner）

### 对齐

在签名前，脚本会使用 `zipalign` 工具对 APK 进行优化对齐，这可以：
- 减少应用运行时的内存占用
- 提高应用性能
- 这是 Google Play 的要求

## 故障排除

**问题：签名失败**
- 检查 Java 是否正确安装
- 确保密钥库文件未损坏
- 查看错误日志

**问题：APK 安装时提示签名冲突**
- 卸载设备上的旧版本应用
- 确保使用相同的密钥库签名

**问题：无法验证签名**
- 确保 APK 签名完成
- 检查 apksigner 或 jarsigner 是否可用
