@echo off
chcp 65001 >nul
echo ==========================================
echo 小远智 - AI模型每日动态监测（手动运行）
echo ==========================================
echo.

PowerShell -ExecutionPolicy Bypass -File "%~dp0daily_ai_report.ps1"

echo.
echo ==========================================
echo 执行完成！按任意键退出...
echo ==========================================
pause >nul
