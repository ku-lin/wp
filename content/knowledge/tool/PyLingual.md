---
title: "PyLingual 中文说明"
draft: false
---
## 1. 这是什么

`PyLingual` 是一个 Python 字节码反编译工具，官方说明支持 `Python 3.6` 之后的已发布 CPython 版本。本地仓库当前 `pyproject.toml` 标注的项目描述是支持 `3.6 - 3.13`，并要求运行环境为 `Python 3.12+`。

它的目标是把 `.pyc` 这类 Python 字节码尽量还原成可读源码，适合：

- 恶意样本分析
- Python 打包程序取证
- PyInstaller 样本辅助还原
- CTF / 逆向场景下的 Python 字节码分析

官方资源：

- 项目仓库：<https://github.com/syssec-utd/pylingual>
- 官网：<https://pylingual.io>
- 论文：<https://www.computer.org/csdl/proceedings-article/sp/2025/223600a052/21B7QZB86cg>

## 2. 当前本机位置

本机已拉取到：

- 仓库目录：`D:\tool\取证\PyLingual`
- 英文说明：`D:\tool\取证\PyLingual\README.md`
- 中文说明：`D:\tool\取证\PyLingual\README_CN.md`

本机当前已实际配置完成的环境：

- Python 解释器：`D:\python\Python312\python.exe`
- 项目虚拟环境：`D:\tool\取证\PyLingual\.venv`
- Poetry：已安装在项目虚拟环境内

本机已验证可用的命令：

```powershell
cd D:\tool\取证\PyLingual
.\.venv\Scripts\poetry.exe run pylingual --help
```

## 3. 它适合干什么

如果你手上遇到的是：

- `.pyc`
- 某些 Python 恶意样本
- 被打包后的 Python 程序里拆出来的字节码

那么 `PyLingual` 可以作为 `pyinstxtractor` 之后的下一步工具来用。

一个常见链路是：

1. 先用 `pyinstxtractor` 解包 PyInstaller 程序
2. 从解包结果中拿到 `.pyc`
3. 再用 `PyLingual` 尝试把字节码还原成源码

## 4. 环境要求

根据当前仓库说明，主要要求是：

- `Python 3.12`
- `Poetry >= 2.0`

如果你需要跨 Python 版本重新编译某些字节码相关内容，官方还提到：

- Linux / macOS 常用 `pyenv`
- Windows 常用 `pyenv-win`

## 5. 安装方式

### 5.1 进入目录

```powershell
cd D:\tool\取证\PyLingual
```

### 5.2 创建虚拟环境

```powershell
python -m venv venv
```

### 5.3 激活虚拟环境

PowerShell：

```powershell
.\venv\Scripts\Activate.ps1
```

CMD：

```cmd
venv\Scripts\activate.bat
```

### 5.4 安装 Poetry

```powershell
pip install "poetry>=2.0"
```

### 5.5 安装依赖

```powershell
poetry lock
poetry install
```

## 6. 运行方式

项目入口命令在 `pyproject.toml` 中定义为：

```text
pylingual = "pylingual.main:main"
```

因此通常有两种启动方式。

### 方式一：通过 Poetry 运行

```powershell
poetry run pylingual --help
```

### 方式二：作为模块运行

```powershell
python -m pylingual.main --help
```

## 7. 常用命令

官方当前 README 中给出的帮助信息如下，下面是更好理解的中文解释。

### 查看帮助

```powershell
poetry run pylingual --help
```

### 基本用法

```powershell
poetry run pylingual sample.pyc
```

### 指定输出目录

```powershell
poetry run pylingual sample.pyc -o .\output
```

### 指定字节码 Python 版本

```powershell
poetry run pylingual sample.pyc -v 3.10
```

### 使用自定义配置文件

```powershell
poetry run pylingual sample.pyc -c .\pylingual\decompiler_config.yaml
```

### 静默运行

```powershell
poetry run pylingual sample.pyc -q
```

## 8. 常见参数说明

- `-o, --out-dir`
  指定输出目录。
- `-c, --config-file`
  指定模型或配置文件。
- `-v, --version`
  指定 `.pyc` 对应的 Python 版本，不指定时默认自动检测。
- `-k, --top-k`
  允许考虑更多候选分段结果。
- `-q, --quiet`
  减少控制台输出。
- `--trust-lnotab`
  使用 `lnotab` 做分段，而不是走分段模型。
- `--init-pyenv`
  在反编译前初始化 `pyenv`。

## 9. 和 pyinstxtractor 的关系

它们不是替代关系，而是互补关系：

- `pyinstxtractor` 更偏“把 PyInstaller 包拆开”
- `PyLingual` 更偏“把拿到的 Python 字节码重新变回源码”

简单理解就是：

- `pyinstxtractor` 负责拆包
- `PyLingual` 负责反编译

## 10. 注意事项

- 它不是所有样本都能百分百完美还原。
- 官方 README 说明，本地代码库更偏可读性和后续扩展，控制流精度一开始可能不如官网托管版本。
- 如果你样本来自不同 Python 版本，版本识别和依赖环境会直接影响结果质量。
- 涉及模型、等价检查或跨版本编译时，环境准备会比普通脚本工具复杂。

## 11. 最推荐的使用姿势

如果你只是做本地分析，建议这样用：

1. 准备 `Python 3.12`
2. 在项目目录创建虚拟环境
3. 安装 `Poetry`
4. `poetry install`
5. 先对单个 `.pyc` 跑 `--help` 和基础命令验证

推荐第一条测试命令：

```powershell
cd D:\tool\取证\PyLingual
.\.venv\Scripts\Activate.ps1
poetry run pylingual --help
```

## 12. 一句话总结

`PyLingual` 适合放在 Python 样本分析链路里，尤其适合接在 `pyinstxtractor` 后面，用来把拆出来的 `.pyc` 尽量还原成源码。

