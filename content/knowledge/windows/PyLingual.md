---
title: "PyLingual"
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：Reverse / Python
- 主要用途：Python 字节码反编译/控制流恢复工具，适合 pyc 或 PyInstaller 提取后的代码恢复。
- 工具位置：`D:\tool\取证\PyLingual`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

PyLingual 的核心价值是：Python 字节码反编译/控制流恢复工具，适合 pyc 或 PyInstaller 提取后的代码恢复。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python -m pylingual --help
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- 当前尝试运行 `python -m pylingual --help` 时缺少 `pydot` 依赖；如需使用 CLI，先在该项目环境中补依赖。

## 完整参数帮助输出

### pylingual --help

```text
Traceback (most recent call last):
  File "<frozen runpy>", line 189, in _run_module_as_main
  File "<frozen runpy>", line 148, in _get_module_details
  File "<frozen runpy>", line 112, in _get_module_details
  File "D:\tool\取证\PyLingual\pylingual\__init__.py", line 1, in <module>
    from .decompiler import decompile
  File "D:\tool\取证\PyLingual\pylingual\decompiler.py", line 40, in <module>
    from pylingual.control_flow_reconstruction.structure import bc_to_cft
  File "D:\tool\取证\PyLingual\pylingual\control_flow_reconstruction\structure.py", line 7, in <module>
    from .cfg import CFG
  File "D:\tool\取证\PyLingual\pylingual\control_flow_reconstruction\cfg.py", line 8, in <module>
    import pydot
ModuleNotFoundError: No module named 'pydot'
```

