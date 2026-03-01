---
name: xiaoyuanzhi-reporter
description: 小远智的报告生成与双同步工具。用于网络信息查询、资料汇总整理成详细报告，并自动同步到GitHub仓库和Obsidian知识库。支持基于用户提供的资料或自主网络搜索，使用Tavily API进行多源新闻聚合，最终生成结构化Markdown报告并推送到指定仓库和本地笔记系统。适用于新闻汇总、研究报告、资料整理等场景。
---

# 小远智的报告

自动化报告生成与**双同步**工具，整合网络搜索、内容汇总、GitHub云端备份和Obsidian本地知识库管理。

## 核心功能

1. **网络信息查询** - 使用 Tavily API 进行多源新闻聚合搜索
2. **资料汇总整理** - 将搜索结果或用户提供的资料整理成结构化报告
3. **双同步机制** - 报告自动同步到：
   - **GitHub** - 云端备份、版本管理、团队协作
   - **Obsidian** - 本地知识库、双向链接、图谱关联
4. **智能索引** - Obsidian 中的索引文件（README.md）自动更新，按类别组织
5. **定时任务支持** - 可配置周期性自动生成报告

## 工作流程

### 标准流程

```
用户请求/定时触发 
    ↓
信息收集（Tavily搜索/用户提供）
    ↓
报告生成（Markdown格式）
    ↓
双同步
    ├──→ GitHub（git push）
    └──→ Obsidian（文件复制+索引更新）
    ↓
完成通知
```

### 详细步骤

#### 1. 信息收集阶段

**方式A：网络搜索（默认）**
- 使用 Tavily API 进行搜索
- API Key 已预配置，直接使用
- 支持多关键词、时间范围、搜索深度设置

**方式B：用户提供资料**
- 接收用户提供的文本、链接、文件等
- 作为报告的主要素材来源

#### 2. 报告生成阶段

生成标准格式的 Markdown 报告，包含：
- 标题与元数据（日期、来源、整理者）
- 执行摘要/核心发现
- 详细内容（分章节组织）
- 关键要点总结表
- 信息来源说明

#### 3. 双同步阶段

##### GitHub 同步
- 保存报告到本地仓库目录
- 自动执行 git add → commit → push
- 提交信息格式：`添加[主题]报告 - YYYY-MM-DD`

##### Obsidian 同步
- 复制报告到 Vault 的 `小远智/` 目录
- 自动更新 `README.md` 索引文件
- 按类别分组（每日监测、AI行业、国际新闻等）
- 支持 `[[双向链接]]` 格式

## 使用方法

### 直接调用

当用户需要以下功能时自动触发：
- "查一下XX的新闻并整理成报告"
- "帮我汇总关于XX的资料"
- "制作一份XX的分析报告"
- "定时每天生成XX报告"

### 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `topic` | 报告主题 | "伊朗以色列冲突" |
| `query` | 搜索关键词 | "Iran Israel war latest news" |
| `sources` | 用户提供的补充资料 | 文本/链接/文件 |
| `schedule` | 定时配置（可选） | "daily", "weekly" |

## 技术实现

### Tavily API 调用

使用已配置的 API Key：`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`

```powershell
$headers = @{
    'Authorization' = 'Bearer <API_KEY>'
    'Content-Type' = 'application/json'
}

$body = @{
    query = "搜索关键词"
    max_results = 10
    time_range = "day"
    search_depth = "advanced"
} | ConvertTo-Json

Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body
```

### 双同步配置

#### GitHub 同步

| 配置项 | 值 |
|--------|-----|
| 目标仓库 | `https://github.com/duzhilei951/-` |
| 本地路径 | `C:\Users\远智教育\.openclaw\workspace\小远智` |
| 功能 | 版本管理、远程备份、团队协作 |

```powershell
Set-Location "C:\Users\远智教育\.openclaw\workspace\小远智"
git add .
git commit -m "添加报告 - $(Get-Date -Format 'yyyy-MM-dd')"
git push origin main
```

#### Obsidian 同步

| 配置项 | 值 |
|--------|-----|
| Vault 路径 | `Y:\000 笔记资料\喜悦天地` |
| 目标文件夹 | `小远智/` |
| 索引文件 | `小远智/README.md` |
| 功能 | 本地知识库、双向链接、图谱关联 |

```powershell
# 复制报告
Copy-Item -Path "$reportPath" -Destination "$ObsidianVaultPath\小远智\" -Force

# 更新索引（自动检测文件并生成索引）
Update-ObsidianIndex -VaultPath "$ObsidianVaultPath" -FolderName "小远智"
```

### 索引文件格式

Obsidian 的 `README.md` 自动维护，格式如下：

```markdown
# 小远智 - 报告索引

> 自动生成的报告集合，同步自 GitHub 仓库  
> 最后更新：2026-03-01 12:00:00

---

## 📊 每日监测

- [[AI模型每日动态_2026-03-01|AI模型每日动态]] - 2026-03-01
...

## 🤖 AI 行业

- [[AI行业最新进展报告_2025-03-01|AI行业最新进展]] - 2025-03-01
...

## 🌍 国际新闻

...

---

*本索引由「小远智的报告」技能自动维护*
```

## 脚本工具

### 主要脚本

| 脚本 | 功能 | 位置 |
|------|------|------|
| `daily_ai_report.ps1` | 定时任务主脚本（搜索+生成+双同步） | `scripts/` |
| `sync-report.ps1` | 独立双同步脚本 | `scripts/` |
| `setup-scheduled-task.ps1` | Windows定时任务配置 | `scripts/` |

### 使用示例

#### 手动运行完整流程
```powershell
cd C:\Users\远智教育\.openclaw\workspace\小远智\scripts
.\daily_ai_report.ps1
```

#### 仅同步现有报告
```powershell
.\sync-report.ps1 -ReportFile "报告路径.md" -ReportTitle "报告标题"
```

#### 配置定时任务
```cmd
schtasks /create /tn "小远智-AI模型每日监测" /tr "PowerShell -ExecutionPolicy Bypass -File C:\Users\远智教育\.openclaw\workspace\小远智\scripts\daily_ai_report.ps1" /sc daily /st 09:00 /f
```

## 定时任务配置

### Windows 任务计划程序

创建每天自动运行的任务：

```powershell
# 以管理员身份运行
$taskName = "小远智-AI模型每日监测"
$scriptPath = "C:\Users\远智教育\.openclaw\workspace\小远智\scripts\daily_ai_report.ps1"

# 创建触发器（每天9:00）
$trigger = New-ScheduledTaskTrigger -Daily -At "09:00"

# 创建操作
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# 注册任务
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Force
```

### 管理命令

```cmd
# 立即运行
schtasks /run /tn "小远智-AI模型每日监测"

# 查看状态
schtasks /query /tn "小远智-AI模型每日监测" /v

# 暂停/恢复
schtasks /change /tn "小远智-AI模型每日监测" /disable
schtasks /change /tn "小远智-AI模型每日监测" /enable

# 删除任务
schtasks /delete /tn "小远智-AI模型每日监测" /f
```

## 报告模板

参考 `references/report-template.md` 中的标准报告格式。

模板包含：
- 标题与元数据
- 核心事件摘要
- 详细内容章节
- 关键要点总结表
- 信息来源说明

## 注意事项

1. **Tavily API 限制**：有速率限制，大量搜索时注意控制频率
2. **报告文件名格式**：`[主题]_YYYY-MM-DD.md`
3. **网络依赖**：GitHub推送和Tavily搜索需要网络连接
4. **编码问题**：Obsidian同步使用UTF-8编码确保中文正常显示
5. **定时任务权限**：Windows定时任务需要管理员权限创建

## 故障排除

### GitHub推送失败
- 检查Git配置：`git config --list`
- 验证仓库权限：`gh auth status`
- 手动测试推送

### Obsidian同步失败
- 检查Vault路径是否正确
- 确认目录权限
- 验证文件编码（应为UTF-8）

### Tavily API错误
- 检查API Key是否有效
- 确认网络连接正常
- 查看速率限制状态

---

*本技能由「小远智」维护和更新*
