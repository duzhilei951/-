# AI模型每日动态监测 - 定时任务配置

## 📋 功能说明

自动每天搜索AI模型最新动态，**仅在有新模型发布或重大升级时**生成报告并推送到GitHub。

### 触发条件
- 🆕 新模型发布（如 GPT-6、Kimi K3 等）
- ⬆️ 重大版本升级（如 V2.0 → V3.0）
- 🔧 重要功能更新或架构改进

### 不触发的情况
- 日常新闻、评论文章
- 小幅优化或补丁更新
- 市场分析、使用教程

---

## 🚀 快速开始

### 方法一：自动配置（推荐）

1. **以管理员身份打开 PowerShell**
   ```powershell
   # 右键点击开始菜单 -> Windows PowerShell (管理员)
   ```

2. **运行配置脚本**
   ```powershell
   cd C:\Users\远智教育\.openclaw\workspace\小远智\scripts
   .\setup-scheduled-task.ps1
   ```

3. **完成！** 任务已设置为每天上午9:00自动运行

### 方法二：手动运行测试

双击运行 `run-now.bat`，查看是否能正常执行并推送报告。

---

## ⚙️ 自定义配置

### 修改执行时间

```powershell
# 查看当前任务
Get-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 修改为每天晚上8点
$trigger = New-ScheduledTaskTrigger -Daily -At "20:00"
Set-ScheduledTask -TaskName "小远智-AI模型每日监测" -Trigger $trigger
```

### 修改监测频率

编辑 `daily_ai_report.ps1` 中的 `$keywordsNewModel` 和 `$keywordsUpdate` 数组，调整检测敏感度。

### 添加关注的模型

在脚本中搜索关键词部分添加新的模型名称：

```powershell
$modelKeywords = @(
    "kimi", "qwen", "deepseek", "glm", "minimax", "doubao",
    "gpt", "claude", "gemini", "llama", "mistral",
    "你的新模型名称"  # <-- 添加到这里
)
```

---

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `daily_ai_report.ps1` | 核心监测脚本 |
| `setup-scheduled-task.ps1` | 定时任务配置脚本 |
| `run-now.bat` | 手动运行批处理 |
| `README.md` | 本说明文档 |
| `../logs/` | 日志文件目录 |

---

## 🔍 查看执行结果

### 查看日志
```powershell
# 查看最新日志
Get-Content C:\Users\远智教育\.openclaw\workspace\小远智\logs\daily_report_$(Get-Date -Format 'yyyyMMdd').log -Tail 50
```

### 检查GitHub仓库
访问 https://github.com/duzhilei951/- 查看是否有新的报告文件生成。

### 查看Windows事件日志
```powershell
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TaskScheduler/Operational'; ID=201} | Where-Object {$_.Message -like "*小远智*"} | Select-Object -First 5
```

---

## 🛠️ 故障排除

### 问题1：任务创建失败
**解决**：确保以管理员身份运行PowerShell

### 问题2：脚本执行无输出
**解决**：检查Tavily API Key是否有效，检查网络连接

### 问题3：GitHub推送失败
**解决**：
1. 检查Git配置：`git config --list`
2. 验证仓库权限：`gh auth status`
3. 手动测试推送：`cd C:\Users\远智教育\.openclaw\workspace\小远智 && git push`

### 问题4：误报/漏报
**解决**：调整 `daily_ai_report.ps1` 中的关键词匹配逻辑

---

## 📝 任务管理命令

```powershell
# 查看任务状态
Get-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 立即运行一次
Start-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 停止正在运行的任务
Stop-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 禁用任务
Disable-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 启用任务
Enable-ScheduledTask -TaskName "小远智-AI模型每日监测"

# 删除任务
Unregister-ScheduledTask -TaskName "小远智-AI模型每日监测" -Confirm:$false
```

---

## 🔄 更新维护

如需修改监测逻辑或添加新功能：

1. 编辑 `daily_ai_report.ps1`
2. 手动运行测试：`run-now.bat`
3. 确认无误后，定时任务会自动使用新版本

---

*由「小远智的报告」技能自动生成*
