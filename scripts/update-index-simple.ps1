# Update Obsidian Index
param([string]$VaultPath = "Y:\000 笔记资料\喜悦天地", [string]$FolderName = "小远智")

$folderPath = Join-Path $VaultPath $FolderName
$indexPath = Join-Path $folderPath "README.md"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Get all markdown files
$files = Get-ChildItem -Path $folderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

# Build index content
$content = @"
# 小远智 - 报告索引

> 自动生成的报告集合，同步自 GitHub 仓库  
> 最后更新：$timestamp

---

## 报告列表

"@

foreach ($file in ($files | Sort-Object LastWriteTime -Descending)) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $date = ""
    if ($baseName -match "(\d{4}-\d{2}-\d{2})") {
        $date = $Matches[1]
    }
    
    $title = $baseName -replace "_", " "
    $entry = "- [[$baseName|$title]]"
    if ($date) {
        $entry += " - $date"
    }
    $content += "$entry`n"
}

$content += @"

---

- GitHub: https://github.com/duzhilei951/-

*本索引由「小远智的报告」技能自动维护*
"@

# Write with UTF-8
[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Index updated: $indexPath"
