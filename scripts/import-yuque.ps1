param(
    [string]$SourceRoot = 'D:\wp\yuque-export\1',
    [string]$SiteRoot = 'S:\wp\blog'
)

$ErrorActionPreference = 'Stop'

function Convert-MarkdownLink {
    param([string]$Target)

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return $Target
    }

    if ($Target -match '^(https?:|mailto:|tel:|#|data:)') {
        return $Target
    }

if ($Target -match '^\.?/img/') {
        return $Target
    }

    if ($Target -match '^\.?/attachments/') {
        return $Target
    }

    $fragment = ''
    $path = $Target
    if ($Target -match '^(?<path>[^#?]+)(?<suffix>[#?].*)$') {
        $path = $matches.path
        $fragment = $matches.suffix
    }

    $path = $path -replace '\\', '/'
    $path = $path -replace '^\./', ''
    $path = $path -replace '^yuque-export/1/', ''

    if ($path -match '\.md$') {
        if ($path -match '(^|/)index\.md$') {
            $path = $path -replace 'index\.md$', ''
        } else {
            $path = ($path -replace '\.md$', '') + '/'
        }
    }

    return $path + $fragment
}

function Convert-MarkdownBody {
    param([string]$Content)

    $pattern = '(?<prefix>!?)\[(?<text>[^\]]*)\]\((?<dest>[^)]+)\)'
    $content = [regex]::Replace($Content, $pattern, {
        param($match)
        $prefix = $match.Groups['prefix'].Value
        $text = $match.Groups['text'].Value
        $dest = $match.Groups['dest'].Value.Trim()
        $newDest = Convert-MarkdownLink -Target $dest
        return "$prefix[$text]($newDest)"
    })

    $content = $content.Replace('{{', '&#123;&#123;')
    $content = $content.Replace('}}', '&#125;&#125;')
    $content = $content.Replace('{%', '&#123;%')
    $content = $content.Replace('%}', '%&#125;')

    $lines = $content -split "`r?`n"
    $inFence = $false
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*```') {
            $inFence = -not $inFence
            continue
        }

        if (-not $inFence) {
            $lines[$i] = $lines[$i].Replace('<script', '&lt;script')
            $lines[$i] = $lines[$i].Replace('</script>', '&lt;/script&gt;')
            $lines[$i] = $lines[$i].Replace('<img', '&lt;img')
            $lines[$i] = $lines[$i].Replace('<body', '&lt;body')
        }
    }

    $content = [string]::Join("`r`n", $lines)

    return $content
}

function Get-BodyContent {
    param([string]$RawContent)

    return $RawContent.TrimStart([char]0xFEFF)
}

function Format-FrontMatterDate {
    param([datetime]$Value)

    return $Value.ToString('yyyy-MM-ddTHH:mm:ssK')
}

$destinationContent = Join-Path $SiteRoot 'content\knowledge'
$destinationStatic = Join-Path $SiteRoot 'static\knowledge'

if (Test-Path -LiteralPath $destinationContent) {
    Remove-Item -LiteralPath $destinationContent -Recurse -Force
}
if (Test-Path -LiteralPath $destinationStatic) {
    Remove-Item -LiteralPath $destinationStatic -Recurse -Force
}

New-Item -ItemType Directory -Path $destinationContent -Force | Out-Null
New-Item -ItemType Directory -Path $destinationStatic -Force | Out-Null

$assetDirectories = Get-ChildItem -LiteralPath $SourceRoot -Recurse -Directory | Where-Object { $_.Name -in @('img', 'attachments') }
foreach ($directory in $assetDirectories) {
    $parentRelative = $directory.Parent.FullName.Substring($SourceRoot.Length).TrimStart('\')
    $destinationAssetDir = if ([string]::IsNullOrWhiteSpace($parentRelative)) {
        Join-Path $destinationStatic $directory.Name
    } else {
        Join-Path (Join-Path $destinationStatic $parentRelative) $directory.Name
    }
    New-Item -ItemType Directory -Path (Split-Path $destinationAssetDir -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $directory.FullName -Destination $destinationAssetDir -Recurse -Force
}

$rootIndex = @'
---
title: "知识库"
description: "CTF、课程、电子取证与日常工具整理"
summary: "从语雀导入的知识库内容。"
---

这里收录了原有语雀导出的笔记、题解和课程整理，入口请从首页专题卡片进入，或直接使用搜索。
'@
Set-Content -LiteralPath (Join-Path $destinationContent '_index.md') -Value $rootIndex -Encoding UTF8

$markdownFiles = Get-ChildItem -LiteralPath $SourceRoot -Recurse -Filter '*.md' | Sort-Object FullName

foreach ($file in $markdownFiles) {
    $relativePath = $file.FullName.Substring($SourceRoot.Length).TrimStart('\')
    $relativePath = $relativePath -replace '\\', '/'

    if ($relativePath -eq 'index.md') {
        continue
    }

    $destinationRelative = $relativePath
    if ([System.IO.Path]::GetFileName($relativePath) -ieq 'index.md') {
        $parent = Split-Path $relativePath -Parent
        $destinationRelative = if ([string]::IsNullOrWhiteSpace($parent)) { '_index.md' } else { ($parent -replace '\\', '/') + '/_index.md' }
    }

    $destinationPath = Join-Path $destinationContent ($destinationRelative -replace '/', '\')
    $destinationDir = Split-Path $destinationPath -Parent
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null

    $raw = Get-Content -LiteralPath $file.FullName -Raw
    $title = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $body = Convert-MarkdownBody -Content (Get-BodyContent -RawContent $raw)
    $lastmod = Format-FrontMatterDate -Value $file.LastWriteTime

    $frontMatter = @(
        '---'
        ('title: "{0}"' -f ($title -replace '"', '\"'))
        ('lastmod: {0}' -f $lastmod)
        'draft: false'
        '---'
        ''
    ) -join "`r`n"

    $output = $frontMatter + $body
    Set-Content -LiteralPath $destinationPath -Value $output -Encoding UTF8
}

$allDirectories = Get-ChildItem -LiteralPath $destinationContent -Recurse -Directory
foreach ($directory in $allDirectories) {
    $indexPath = Join-Path $directory.FullName '_index.md'
    if (-not (Test-Path -LiteralPath $indexPath)) {
        $title = $directory.Name
        $lastmod = Format-FrontMatterDate -Value $directory.LastWriteTime
        $content = @(
            '---'
            ('title: "{0}"' -f ($title -replace '"', '\"'))
            ('lastmod: {0}' -f $lastmod)
            'draft: false'
            '---'
            ''
            ('{0} 目录。' -f $title)
        ) -join "`r`n"
        Set-Content -LiteralPath $indexPath -Value $content -Encoding UTF8
    }
}
