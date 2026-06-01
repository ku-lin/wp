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
    return [regex]::Replace($Content, $pattern, {
        param($match)
        $prefix = $match.Groups['prefix'].Value
        $text = $match.Groups['text'].Value
        $dest = $match.Groups['dest'].Value.Trim()
        $newDest = Convert-MarkdownLink -Target $dest
        return "$prefix[$text]($newDest)"
    })
}

function Get-TitleAndBody {
    param([string]$RawContent, [string]$FallbackTitle)

    $content = $RawContent.TrimStart([char]0xFEFF)
    $title = $FallbackTitle

    $headingMatch = [regex]::Match($content, '(?m)^#\s+(.+?)\s*$')
    if ($headingMatch.Success) {
        $title = $headingMatch.Groups[1].Value.Trim()
    }

    $body = [regex]::Replace($content, '\A#\s+.+?\r?\n(\r?\n)?', '', 1)
    $body = $body.TrimStart()

    return @{
        Title = $title
        Body  = $body
    }
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

$imageDirectories = Get-ChildItem -LiteralPath $SourceRoot -Recurse -Directory | Where-Object { $_.Name -eq 'img' }
foreach ($directory in $imageDirectories) {
    $parentRelative = $directory.Parent.FullName.Substring($SourceRoot.Length).TrimStart('\')
    $destinationImageDir = if ([string]::IsNullOrWhiteSpace($parentRelative)) {
        Join-Path $destinationStatic 'img'
    } else {
        Join-Path (Join-Path $destinationStatic $parentRelative) 'img'
    }
    New-Item -ItemType Directory -Path (Split-Path $destinationImageDir -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $directory.FullName -Destination $destinationImageDir -Recurse -Force
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
    $fallbackTitle = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $parts = Get-TitleAndBody -RawContent $raw -FallbackTitle $fallbackTitle
    $body = Convert-MarkdownBody -Content $parts.Body

    $frontMatter = @(
        '---'
        ('title: "{0}"' -f ($parts.Title -replace '"', '\"'))
        'draft: false'
        '---'
        ''
    ) -join "`r`n"

    $output = $frontMatter + $body
    Set-Content -LiteralPath $destinationPath -Value $output -Encoding UTF8
}
