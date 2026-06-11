# APK 修改自动化工具

一个自动化的 Android APK 修改工具链，支持解包、修改、重打包和签名。本项目使用 APKTool 对 Android 应用进行逆向工程实践。

## 功能特性

- 🔧 **自动解包和重打包** - 使用 APKTool 完整处理 APK
- ⚙️ **配置化修改** - 通过 JSON 配置文件定义修改内容
- ✍️ **自动签名** - 自动生成调试密钥并签名 APK
- ✅ **完整验证** - 生成详细的验证报告
- 📝 **模块化设计** - 每个步骤可独立执行

## 环境要求

- **Java** 17 或更高版本
- **Git Bash** (Windows) 或 **Bash** (Linux/macOS)

## 准备工作

### 1. 下载 APKTool

下载 [APKTool 2.11.1](https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar) 并放在项目根目录。

```bash
# Linux/macOS
wget https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar

# Windows (PowerShell)
curl -L -o apktool_2.11.1.jar https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar
```

### 2. 准备测试 APK

将待修改的 APK 文件放在项目根目录，或使用环境变量指定路径：

```bash
# 方法 1: 放在项目根目录（默认文件名）
cp your-downloaded-app.apk your-app.apk

# 方法 2: 使用环境变量指定任意 APK
export APK_FILE=/path/to/your-app.apk
bash scripts/run-all.sh
```

可选工具（用于更详细的验证）：
- `aapt` - Android Asset Packaging Tool
- `apksigner` - APK 签名工具

## 项目结构

```
apk-mod-project/
├── scripts/              # 脚本目录
│   ├── lib/             # 公共库
│   │   ├── common.sh    # 日志和错误处理
│   │   └── config.sh    # 路径配置
│   ├── 01-decompile.sh  # APK 解包
│   ├── 02-modify.sh     # 内容修改
│   ├── 03-rebuild.sh    # APK 重打包
│   ├── 04-sign.sh       # APK 签名
│   ├── 05-verify.sh     # 验证和报告
│   └── run-all.sh       # 一键执行所有步骤
├── mods/
│   └── config.json      # 修改配置文件
├── output/              # 输出目录（自动生成）
│   ├── decompiled/      # 解包后的文件
│   ├── modified.apk     # 重打包的 APK（未签名）
│   ├── signed.apk       # 最终签名的 APK
│   └── logs/            # 日志文件
└── keystore/            # 密钥库目录
    └── debug.keystore   # 调试签名密钥（自动生成）
```

## 快速开始

### 1. 配置修改内容

编辑 `mods/config.json` 文件，定义你想要的修改：

```json
{
  "app_info": {
    "new_version_name": "1.7.0-modded",
    "new_version_code": "14"
  },
  "strings": {
    "app_launcher_name": "Notes Mod",
    "app_name": "Fossify Notes Modified"
  },
  "manifest": {
    "debuggable": "true"
  }
}
```

### 2. 执行修改

**一键执行所有步骤：**

```bash
bash scripts/run-all.sh
```

**或者分步执行：**

```bash
bash scripts/01-decompile.sh  # 解包 APK
bash scripts/02-modify.sh     # 修改内容
bash scripts/03-rebuild.sh    # 重打包
bash scripts/04-sign.sh       # 签名
bash scripts/05-verify.sh     # 验证
```

### 3. 获取结果

修改后的 APK 位于 `output/signed.apk`，可以直接安装到 Android 设备。

验证报告保存在 `output/verification_report.txt`。

## 配置说明

### config.json 字段说明

| 字段 | 说明 | 示例 |
|------|------|------|
| `new_version_name` | 新的版本名称 | `"1.7.0-modded"` |
| `new_version_code` | 新的版本号 | `"14"` |
| `app_launcher_name` | 桌面显示名称 | `"Notes Mod"` |
| `app_name` | 应用完整名称 | `"Fossify Notes Modified"` |
| `debuggable` | 是否启用调试模式 | `"true"` 或 `"false"` |

## 修改内容

本项目对 Fossify Notes 应用进行以下修改：

1. **应用名称**
   - 桌面显示名：`Notes` → `Notes Mod`
   - 完整名称：`Fossify Notes` → `Fossify Notes Modified`

2. **版本信息**
   - 版本名：`1.7.0` → `1.7.0-modded`
   - 版本号：`13` → `14`

3. **调试支持**
   - 启用 `android:debuggable="true"`

这些修改是安全的，不会破坏应用的核心功能。

## 验证报告示例

运行 `05-verify.sh` 后，会生成类似以下的报告：

```
===== APK 修改验证报告 =====
生成时间: 2026-06-11 14:30:00

原始 APK: notes-13-foss-release.apk
  大小: 9.1M

修改后 APK: signed.apk
  大小: 9.2M

修改项目:
  ✓ 应用启动名称: Notes → Notes Mod
  ✓ 应用完整名称: Fossify Notes → Fossify Notes Modified
  ✓ 版本名称: 1.7.0 → 1.7.0-modded
  ✓ 版本号: 13 → 14
  ✓ 调试模式: 已启用

签名验证:
  ✓ 签名有效

验证结果: 全部完成 ✓
```

## 常见问题

### Q: APK 安装失败怎么办？

A: 确保：
1. 卸载了原版应用（包名冲突）
2. 在设备设置中允许安装未知来源的应用
3. APK 签名正确（查看验证报告）

### Q: 修改没有生效？

A: 检查：
1. `config.json` 格式是否正确
2. 运行 `02-modify.sh` 时是否有错误信息
3. 重新运行完整流程 `bash scripts/run-all.sh`

### Q: Windows 下脚本无法执行？

A: 使用 Git Bash 运行脚本，不要使用 CMD 或 PowerShell。

### Q: 密钥库丢失了怎么办？

A: 脚本会自动重新生成密钥库。注意：新密钥生成的签名与旧签名不兼容。

## 技术细节

### 工作流程

1. **解包** - 使用 APKTool 将 APK 反编译为 Smali 代码和资源文件
2. **修改** - 根据配置文件修改 XML 和配置文件
3. **重打包** - 使用 APKTool 将修改后的文件重新打包
4. **对齐** - 使用 zipalign 优化 APK
5. **签名** - 使用 jarsigner 或 apksigner 签名
6. **验证** - 检查签名和修改内容

### 签名说明

本项目使用调试签名（debug keystore），仅用于学习和测试。

## 技术说明

**测试 APK:** Fossify Notes v1.7.0（开源应用）

**工具链:**
- APKTool 2.11.1 - APK 反编译和重打包
- Java keytool/jarsigner - 签名工具
- aapt - APK 信息提取（可选）

