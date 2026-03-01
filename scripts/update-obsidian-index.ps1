# 更新 Obsidian 索引文件
param(
    [string]$VaultPath = "Y:\000 笔记资料\喜悦天地",
    [string]$FolderName = "小远智"
)

$folderPath = Join-Path $VaultPath $FolderName
$indexPath = Join-Path $folderPath "README.md"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 获取所有 markdown 文件（排除索引文件）
$files = Get-ChildItem -Path $folderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

# 按类别分组
$categories = @{
    "📊 每日监测" = @()
    "🤖 AI 行业" = @()
    "🌍 国际新闻" = @()
    "🏆 模型对比" = @()
    "🧪 测试报告" = @()
    "📁 其他" = @()
}

foreach ($file in $files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $date = ""
    if ($baseName -match "(\d{4}-\d{2}-\d{2})") {
        $date = $Matches[1]
    }
    
    # 确定类别
    $category = "📁 其他"
    if ($baseName -match "每日动态") { $category = "📊 每日监测" }
    elseif ($baseName -match "AI行业|人工智能") { $category = "🤖 AI 行业" }
    elseif ($baseName -match "伊朗|冲突|战争|国际") { $category = "🌍 国际新闻" }
    elseif ($baseName -match "国产|大模型|对比|Kimi|Qwen|DeepSeek|GLM|MiniMax") { $category = "🏆 模型对比" }
    elseif ($baseName -match "测试|演示") { $category = "🧪 测试报告" }
    
    # 创建友好标题
    $title = $baseName -replace "_", " " -replace "^(.*?)_(\d{4}-\d{2}-\d{2})$", '$1'
    
    $entry = "- [[$baseName|$title]]"
    if ($date) {
        $entry += " - $date"
    }
    
    $categories[$category] += $entry
}

# 生成索引内容
$content = @"
# 小远智 - 报告索引

> 自动生成的报告集合，同步自 GitHub 仓库  
> 最后更新：$timestamp

---

"@

foreach ($category in $categories.Keys | Sort-Object) {
    $items = $categories[$category]
    $content += "## $category`n`n"
    
    if ($items.Count -eq 0) {
        $content += "*暂无报告*`n`n"
    } else {
        foreach ($item in ($items | Sort-Object -Descending)) {
            $content += "$item`n"
        }
        $content += "`n"
    }
}

$content += @"
---

## 🔗 相关链接

- **GitHub 仓库**：https://github.com/duzhilei951/-
- **定时任务**：每天上午 9:00 自动监测 AI 模型动态

---

*本索引由「小远智的报告」技能自动维护*
"@

# 使用 UTF-8 without BOM 写入
[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.UTF8Encoding]::new($false))

Write-Host "✅ Obsidian 索引已更新: $indexPath" -ForegroundColor Green
