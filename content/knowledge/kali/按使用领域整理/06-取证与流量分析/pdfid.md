---
title: "PDFiD 使用方法"
lastmod: 2026-04-24T14:49:23+08:00
draft: false
---
## 工具信息

- 工具名称：`PDFiD`
- 当前版本：`0.2.9`
- 官方来源：`https://blog.didierstevens.com/2024/11/02/update-pdfid-py-version-0-2-9/`
- 官方下载：`https://didierstevens.com/files/software/pdfid_v0_2_9.zip`
- 本机存放目录：`D:\tool\取证\pdfid`
- 解压后目录：`D:\tool\取证\pdfid\pdfid_v0_2_9`
- 主程序：`D:\tool\取证\pdfid\pdfid_v0_2_9\pdfid.py`

## 这是什么

`PDFiD` 是 Didier Stevens 编写的 PDF 快速静态筛查工具，适合在取证、恶意文档排查、应急响应里做首轮判断。

它不会像完整 PDF 解析器那样深度还原所有对象，而是优先统计高风险关键字和结构特征，比如：

- `/JS`
- `/JavaScript`
- `/OpenAction`
- `/AA`
- `/Launch`
- `/EmbeddedFile`
- `/ObjStm`
- `/Encrypt`
- `/URI`

因此它非常适合做“先筛一遍，找可疑样本”的工作。

## 运行前提

本机已经安装 Python。当前环境可直接使用：

```powershell
python --version
```

进入工具目录：

```powershell
Set-Location "D:\tool\取证\pdfid\pdfid_v0_2_9"
```

查看帮助：

```powershell
python .\pdfid.py -h
```

查看版本：

```powershell
python .\pdfid.py --version
```

## 最常用命令

### 1. 扫描单个 PDF

```powershell
python .\pdfid.py "D:\samples\test.pdf"
```

### 2. 一次扫描多个 PDF

```powershell
python .\pdfid.py "D:\samples\a.pdf" "D:\samples\b.pdf" "D:\samples\c.pdf"
```

### 3. 使用通配符扫描一批 PDF

```powershell
python .\pdfid.py "D:\samples\*.pdf"
```

### 4. 扫描整个目录

`-s` 会递归扫描目录中的文件和子目录。

```powershell
python .\pdfid.py -s "D:\samples"
```

### 5. 对参数中的通配符开启递归目录展开

这个选项适合你不是直接给目录，而是给通配符或 `@文件列表` 时使用。

```powershell
python .\pdfid.py --recursedir "D:\samples\*.pdf"
```

### 6. 隐藏计数为 0 的项目

输出更紧凑，适合快速看可疑点。

```powershell
python .\pdfid.py -n "D:\samples\test.pdf"
```

### 7. 显示更多名称

`-a` 会显示更多 PDF 名称信息，适合更细一点的静态查看。

```powershell
python .\pdfid.py -a "D:\samples\test.pdf"
```

### 8. 显示额外信息

`-e` 会显示额外数据，例如日期类信息。

```powershell
python .\pdfid.py -e "D:\samples\test.pdf"
```

### 9. 强制扫描

有些样本没有标准 `%PDF` 文件头，或者头部被破坏，可以用 `-f` 强制扫描。

```powershell
python .\pdfid.py -f "D:\samples\suspect.bin"
```

### 10. 输出到日志文件

```powershell
python .\pdfid.py -s "D:\samples" -o "D:\tool\取证\pdfid\scan.log"
```

## 使用 `@文件列表`

先准备一个文本文件，每行一个目标：

```text
D:\samples\a.pdf
D:\samples\b.pdf
D:\samples\c.pdf
```

假设保存为 `D:\tool\取证\pdfid\targets.txt`，执行：

```powershell
python .\pdfid.py "@D:\tool\取证\pdfid\targets.txt"
```

如果你已经在文件所在目录，也可以这样：

```powershell
python .\pdfid.py "@targets.txt"
```

## 扫描 ZIP 和 URL

### 扫描 ZIP

`PDFiD` 支持把 ZIP 当输入对象处理：

```powershell
python .\pdfid.py "D:\samples\maldocs.zip"
```

### 扫描 URL

```powershell
python .\pdfid.py "https://example.com/test.pdf"
```

如果你在实战环境中处理未知恶意样本，建议先下载到本地、校验哈希后再分析，不要直接对不可信 URL 做联网拉取。

## Disarm 用法

`-d` 用于尝试去除 PDF 中的 JavaScript 和自动启动类行为，生成一个“去武装”版本。

```powershell
python .\pdfid.py -d "D:\samples\suspect.pdf"
```

生成的文件名通常是：

```text
D:\samples\suspect.disarmed.pdf
```

注意：

- 这不是“彻底清洗”保证，只是辅助处理。
- 原始证据文件不要覆盖，建议始终对副本操作。

## 插件用法

解压目录里自带 3 个插件：

- `plugin_triage.py`
- `plugin_embeddedfile.py`
- `plugin_nameobfuscation.py`

### 1. Triage 插件

这个插件会给样本打一个风险分数，适合批量初筛。

```powershell
python .\pdfid.py -p .\plugin_triage.py "D:\samples\test.pdf"
```

批量跑目录并只显示分数不低于 `0.50` 的结果：

```powershell
python .\pdfid.py -p .\plugin_triage.py -m 0.50 --recursedir "D:\samples\*.pdf"
```

以 CSV 形式输出，适合后续整理：

```powershell
python .\pdfid.py -p .\plugin_triage.py -c --recursedir "D:\samples\*.pdf"
```

### 2. EmbeddedFile 插件

用于判断是否存在嵌入文件对象。

```powershell
python .\pdfid.py -p .\plugin_embeddedfile.py "D:\samples\test.pdf"
```

批量筛带嵌入文件的 PDF：

```powershell
python .\pdfid.py -p .\plugin_embeddedfile.py -m 0.90 --recursedir "D:\samples\*.pdf"
```

### 3. Name Obfuscation 插件

用于识别名称混淆迹象。

```powershell
python .\pdfid.py -p .\plugin_nameobfuscation.py "D:\samples\test.pdf"
```

批量跑：

```powershell
python .\pdfid.py -p .\plugin_nameobfuscation.py --recursedir "D:\samples\*.pdf"
```

## `-S` 选择表达式用法

`-S` 可以按条件过滤结果。脚本里会把当前 PDF 暴露为变量 `pdf`。

常用属性包括：

- `pdf.js.count`
- `pdf.javascript.count`
- `pdf.openaction.count`
- `pdf.aa.count`
- `pdf.launch.count`
- `pdf.embeddedfile.count`
- `pdf.encrypt.count`
- `pdf.objstm.count`
- `pdf.page.count`

### 1. 只显示包含脚本或自动动作的 PDF

```powershell
python .\pdfid.py -S "pdf.js.count > 0 or pdf.javascript.count > 0 or pdf.openaction.count > 0 or pdf.aa.count > 0" --recursedir "D:\samples\*.pdf"
```

### 2. 只显示包含嵌入文件或启动行为的 PDF

```powershell
python .\pdfid.py -S "pdf.embeddedfile.count > 0 or pdf.launch.count > 0" --recursedir "D:\samples\*.pdf"
```

### 3. 只显示加密 PDF

```powershell
python .\pdfid.py -S "pdf.encrypt.count > 0" --recursedir "D:\samples\*.pdf"
```

### 4. 只显示对象流不为 0 的 PDF

```powershell
python .\pdfid.py -S "pdf.objstm.count > 0" --recursedir "D:\samples\*.pdf"
```

## 结果怎么看

典型输出里你会看到这些字段：

- `obj` 和 `endobj`
- `stream` 和 `endstream`
- `xref`
- `trailer`
- `startxref`
- `/Page`
- `/Encrypt`
- `/ObjStm`
- `/JS`
- `/JavaScript`
- `/AA`
- `/OpenAction`
- `/AcroForm`
- `/JBIG2Decode`
- `/RichMedia`
- `/Launch`
- `/EmbeddedFile`
- `/XFA`
- `/URI`

实战里可以这样理解：

- `/JS` 或 `/JavaScript` 不为 0：说明可能存在脚本。
- `/OpenAction` 或 `/AA` 不为 0：说明可能有打开即触发、自动动作。
- `/Launch` 不为 0：较高风险，可能尝试启动外部对象。
- `/EmbeddedFile` 不为 0：说明 PDF 内可能藏有附件或嵌入文件。
- `/Encrypt` 不为 0：说明 PDF 被加密。
- `/ObjStm` 不为 0：说明存在对象流，分析时可能需要进一步展开。
- `/URI` 不为 0：可能存在外联地址、钓鱼链接或载荷下载链接。
- `obj` 和 `endobj` 数量异常，或 `stream` 和 `endstream` 不匹配：值得进一步深挖。

## 推荐的取证排查命令组合

### 1. 快速初筛目录

```powershell
Set-Location "D:\tool\取证\pdfid\pdfid_v0_2_9"
python .\pdfid.py -n -s "D:\samples" -o "D:\tool\取证\pdfid\quick_scan.log"
```

### 2. 专门抓“带脚本或自动动作”的 PDF

```powershell
Set-Location "D:\tool\取证\pdfid\pdfid_v0_2_9"
python .\pdfid.py -S "pdf.js.count > 0 or pdf.javascript.count > 0 or pdf.openaction.count > 0 or pdf.aa.count > 0" --recursedir "D:\samples\*.pdf" -o "D:\tool\取证\pdfid\js_or_autoaction.log"
```

### 3. 用 Triage 插件做批量打分

```powershell
Set-Location "D:\tool\取证\pdfid\pdfid_v0_2_9"
python .\pdfid.py -p .\plugin_triage.py -m 0.50 -c --recursedir "D:\samples\*.pdf" > "D:\tool\取证\pdfid\triage.csv"
```

### 4. 对高危样本做去武装副本

```powershell
Set-Location "D:\tool\取证\pdfid\pdfid_v0_2_9"
python .\pdfid.py -d "D:\samples\high_risk.pdf"
```

## 注意事项

- `PDFiD` 适合做首轮筛查，不等于完整恶意分析。
- 发现高危特征后，建议继续配合 `pdf-parser.py`、沙箱、静态字符串分析、YARA 等手段。
- `-d` 生成的 `.disarmed.pdf` 只能作为辅助样本，不要替代原始证据。
- 如果是办案或正式取证，建议先固定原件哈希，再对副本操作。
- 如果 PowerShell 对 `@文件名` 或通配符处理不符合预期，优先把参数放进引号里。

## 本机已下载文件

当前目录内容：

- `D:\tool\取证\pdfid\pdfid_v0_2_9.zip`
- `D:\tool\取证\pdfid\pdfid_v0_2_9\pdfid.py`
- `D:\tool\取证\pdfid\pdfid_v0_2_9\plugin_triage.py`
- `D:\tool\取证\pdfid\pdfid_v0_2_9\plugin_embeddedfile.py`
- `D:\tool\取证\pdfid\pdfid_v0_2_9\plugin_nameobfuscation.py`


