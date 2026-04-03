# ILRepack Plugin Packer Script
# 使用方法: .\Pack-Plugin.ps1

param(
    [string]$Configuration = "Release",
    [string]$OutputDir = "$env:AppData\Emby-Server\programdata\plugins"
)

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = "$ProjectRoot\StrmAssistant\bin\$Configuration\net6.0"
$MainDll = "$BinDir\StrmAssistant.dll"
$DepsToMerge = @("0Harmony.dll", "ChineseConverter.dll", "TinyPinyin.dll")

# 检查输入文件
Write-Host "检查编译输出..." -ForegroundColor Cyan
if (-not (Test-Path $MainDll)) {
    Write-Error "主 DLL 不存在: $MainDll"
    exit 1
}

foreach ($dll in $DepsToMerge) {
    $dllPath = "$BinDir\$dll"
    if (-not (Test-Path $dllPath)) {
        Write-Warning "依赖 DLL 不存在: $dllPath"
    } else {
        Write-Host "✓ 找到 $dll"
    }
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    Write-Host "创建输出目录: $OutputDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# 当前 ILRepack 暂不支持 .NET 6 完全合并，改为直接复制主 DLL
# 如需完整合并，可使用 ILMerge.Net.Core (NuGet) 等替代工具
Write-Host "复制 StrmAssistant.dll 到 $OutputDir" -ForegroundColor Cyan
Copy-Item -Path $MainDll -Destination "$OutputDir\StrmAssistant.dll" -Force
$pdbFile = "$BinDir\StrmAssistant.pdb"
if (Test-Path $pdbFile) {
    Copy-Item -Path $pdbFile -Destination "$OutputDir\StrmAssistant.pdb" -Force
    Write-Host "✓ 符号文件已复制"
}

Write-Host "✓ 打包完成！" -ForegroundColor Green
Write-Host "输出位置: $OutputDir\StrmAssistant.dll"

# 注：依赖 DLL (0Harmony, ChineseConverter, TinyPinyin) 需要单独部署到 Emby 插件目录
# 或使用更高版本的打包工具 (如 ILMerge.Net.Core) 来完整合并
