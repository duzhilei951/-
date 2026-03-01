# 小远智 - 报告双同步脚本
# 功能：将报告同步到 GitHub 和 Obsidian

param(
    [string]$ReportFile,
    [string]$ReportTitle
)

$ErrorActionPreference = "Stop"
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 路径配置
$WorkspacePath = "C:\Users\远智教育\.openclaw\workspace\小远智"
$ObsidianVaultPath = "Y:\000 笔记资料\喜悦天地"
$ObsidianTargetFolder = "小远智"
$GithubRepo = "duzhilei951/-"

Write-Host "[$timestamp] 开始双同步报告: $ReportFile" -ForegroundColor Green

# 确保报告文件存在
if (!(Test-Path $ReportFile)) {
    Write-Error "报告文件不存在: $ReportFile"
    exit 1
}

# ============================================
# 第一步：同步到 GitHub
# ============================================
Write-Host "步骤1/3: 推送到 GitHub..." -ForegroundColor Cyan

try {
    Set-Location $WorkspacePath
    
    # 配置git（如果未配置）
    git config user.email "xiaoyuanzhi@auto.report" 2>$null
    git config user.name "小远智" 2>$null
    
    # 添加、提交、推送
    git add .
    $commitMsg = "添加报告: $ReportTitle - $date"
    git commit -m $commitMsg 2>$null
    git push origin main
    
    Write-Host "✅ GitHub 同步成功" -ForegroundColor Green
} catch {
    Write-Warning "GitHub 同步可能已完成或无需更新: $_"
}

# ============================================
# 第二步：同步到 Obsidian
# ============================================
Write-Host "步骤2/3: 同步到 Obsidian..." -ForegroundColor Cyan

try {
    # 创建目标目录（如果不存在）
    $obsidianFolder = Join-Path $ObsidianVaultPath $ObsidianTargetFolder
    if (!(Test-Path $obsidianFolder)) {
        New-Item -ItemType Directory -Path $obsidianFolder -Force | Out-Null
        Write-Host "创建Obsidian目录: $obsidianFolder" -ForegroundColor Yellow
    }
    
    # 复制报告文件
    $reportFileName = Split-Path $ReportFile -Leaf
    $obsidianReportPath = Join-Path $obsidianFolder $reportFileName
    Copy-Item -Path $ReportFile -Destination $obsidianReportPath -Force
    Write-Host "✅ 报告已复制到Obsidian: $obsidianReportPath" -ForegroundColor Green
    
    # ============================================
    # 第三步：更新Obsidian索引文件
    # ============================================
    Write-Host "步骤3/3: 更新Obsidian索引..." -ForegroundColor Cyan
    
    $indexFilePath = Join-Path $obsidianFolder "README.md"
    
    # 读取现有索引或创建新索引
    $indexContent = ""
    if (Test-Path $indexFilePath) {
        $indexContent = Get-Content $indexFilePath -Raw -Encoding UTF8
    }
    
    # 如果没有索引内容，创建基础结构
    if ([string]::IsNullOrWhiteSpace($indexContent)) {
        $indexContent = @"
# 小远智 - 报告索引

> 自动生成的报告集合，同步自GitHub仓库
> 最后更新：$timestamp

---

## 📁 报告列表

"@
    } else {
        # 更新最后更新时间
        $indexContent = $indexContent -replace "> 最后更新：.*", "> 最后更新：$timestamp"
    }
    
    # 提取报告类型和日期
    $reportBaseName = [System.IO.Path]::GetFileNameWithoutExtension($reportFileName)
    $reportDate = ""
    if ($reportBaseName -match "(\d{4}-\d{2}-\d{2})") {
        $reportDate = $Matches[1]
    }
    
    # 确定报告类别
    $category = "其他"
    if ($reportBaseName -match "AI模型每日动态") { $category = "📊 每日监测" }
    elseif ($reportBaseName -match "国产大模型") { $category = "🏆 模型对比" }
    elseif ($reportBaseName -match "伊朗|冲突|战争") { $category = "🌍 国际新闻" }
    elseif ($reportBaseName -match "AI行业") { $category = "🤖 AI行业" }
    
    # 创建新的索引条目
    $newEntry = "- [[$reportBaseName|$reportTitle]] - $reportDate`n"
    
    # 检查是否已存在该条目
    if (!$indexContent.Contains("[[$reportBaseName|")) {
        # 根据类别插入到对应位置
        $categoryPattern = "## $category"
        if ($indexContent -match [regex]::Escape($categoryPattern)) {
            # 在对应类别下添加
            $indexContent = $indexContent -replace "($categoryPattern.*?)(\n## |$)", "`$1$newEntry`$2"
        } else {
            # 添加新类别
            $indexContent += @"

## $category

$newEntry
"@
        }
        
        # 保存索引文件
        $indexContent | Out-File -FilePath $indexFilePath -Encoding UTF8
        Write-Host "✅ Obsidian索引已更新" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ 索引中已存在该报告，跳过更新" -ForegroundColor Gray
    }
    
} catch {
    Write-Error "Obsidian同步失败: $_"
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ 双同步完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "📍 GitHub: https://github.com/$GithubRepo" -ForegroundColor Cyan
Write-Host "📍 Obsidian: $ObsidianVaultPath\$ObsidianTargetFolder\" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
