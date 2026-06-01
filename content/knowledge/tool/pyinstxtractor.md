---
title: "pyinstxtractor 中文使用说明"
draft: false
---
## 项目简介

`pyinstxtractor.py` 是一个用于提取 `PyInstaller` 打包生成可执行文件内容的脚本。

它的主要用途是：

- 分析由 `PyInstaller` 打包的 `exe` 或其他可执行文件
- 提取其中的 `pyc`、模块文件、资源文件和内嵌的 `PYZ` 归档
- 为后续反编译和取证分析提供基础文件

脚本本身不依赖 `PyInstaller` 环境，直接运行即可。

## 适用范围

根据脚本头部说明，当前版本支持的 `PyInstaller` 范围覆盖：

- `PyInstaller 2.0`
- 一直到 `PyInstaller 6.19.0`

如果目标文件不是 `PyInstaller` 打包，或者封包结构被破坏，脚本会提示无法识别。

## 环境要求

- 已安装 `Python`
- 建议使用与目标程序打包时相同版本的 `Python`

这是因为脚本在提取 `PYZ` 内容时需要进行反序列化；如果当前运行脚本的 `Python` 版本与目标程序使用的版本不一致，可能出现：

- `PYZ` 无法正常解包
- `marshal` 反序列化失败
- 仅能提取部分文件

## 文件说明

仓库当前核心文件：

- `pyinstxtractor.py`：主提取脚本

## 基本用法

将脚本放到目标样本同目录，或直接使用完整路径执行：

```powershell
python pyinstxtractor.py <文件名>
```

示例：

```powershell
python pyinstxtractor.py sample.exe
```

如果脚本和样本不在同一目录，也可以这样执行：

```powershell
python pyinstxtractor.py D:\samples\sample.exe
```

Linux / macOS 下用法类似：

```bash
python pyinstxtractor.py ./sample
```

## 提取结果

脚本执行成功后，会在当前工作目录下生成一个新的提取目录：

```text
<目标文件名>_extracted
```

例如：

```text
sample.exe_extracted
```

该目录中通常会包含：

- 提取出的 `pyc` 文件
- 原始资源文件
- 可能的入口脚本
- 内嵌 `PYZ` 文件及其展开目录

如果存在 `PYZ` 归档，还会生成类似目录：

```text
<PYZ文件名>_extracted
```

## 输出内容说明

脚本在提取过程中会根据文件类型做不同处理：

- `s` 类型：通常视为 Python 源入口，保存为 `.pyc`
- `m` / `M` 类型：通常为模块或包，保存为 `.pyc`
- `z` / `Z` 类型：通常为 `PYZ` 归档，会继续尝试解包
- 其他类型：按原始数据直接写出

脚本还会：

- 自动修复提取出的部分 `pyc` 文件头
- 尝试输出可能的入口点文件名
- 自动创建子目录结构
- 处理部分非法文件名，避免写出到提取目录之外

## 常见执行流程

运行命令后，通常会看到类似信息：

- 正在处理的目标文件
- 识别出的 `PyInstaller` 版本
- 识别出的 `Python` 版本
- `CArchive` 中文件数量
- 可能的入口点文件
- 是否成功提取

成功后脚本会提示：

- 已成功提取 `PyInstaller` 归档
- 可以继续对提取出的 `pyc` 文件进行反编译

## 常见问题

### 1. 提示 `Missing cookie`

可能原因：

- 目标文件不是 `PyInstaller` 打包
- 文件被截断或已损坏
- 使用了当前脚本未兼容的特殊变种或修改版封包

### 2. 提示 Python 版本不一致

这表示当前运行脚本的 `Python` 版本，与目标程序打包时使用的版本不同。

影响：

- 普通文件可能仍能提取
- `PYZ` 解包可能会被跳过

建议：

- 根据脚本输出的 `Python version: x.y`，切换到对应版本后重新运行

### 3. 提示 `Unmarshalling FAILED`

通常表示：

- `PYZ` 内容无法按当前 `Python` 版本正确反序列化
- 目标样本做了特殊处理

这种情况下，脚本一般仍会继续提取其余可提取文件。

### 4. 提示解压失败或出现 `.encrypted`

说明对应内容可能：

- 被加密
- 被篡改
- 压缩数据已损坏

脚本会尽量保留原始数据，便于后续人工分析。

## 反编译建议

提取完成后，可以继续对 `.pyc` 文件使用 Python 反编译工具进行分析。

典型流程如下：

1. 使用本脚本提取 `PyInstaller` 封包
2. 确认可能的入口点文件
3. 对提取出的 `.pyc` 文件进行反编译
4. 结合资源文件、配置文件和字符串进一步分析逻辑

## 注意事项

- 建议在隔离环境中分析未知样本
- 建议保留原始样本备份
- 该脚本主要用于提取，不等于完整逆向还原
- 某些加密、混淆或魔改样本可能只能部分提取
- 请仅在合法授权场景下使用

## 快速示例

```powershell
python pyinstxtractor.py malware_sample.exe
```

执行后若成功，当前目录下会生成：

```text
malware_sample.exe_extracted
```

你可以优先关注：

- 入口点对应的 `.pyc`
- `PYZ` 解包后的模块目录
- 配置文件、证书、资源文件等附加内容

## 参考信息

- 原项目：`https://github.com/extremecoders-re/pyinstxtractor`
- 作者：`Extreme Coders`
- 协议：`GPLv3`

