@echo off
setlocal
set "BAT_PATH=%~f0"
set "BAT_DIR=%~dp0"
set "ARG1=%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $s=[IO.File]::ReadAllText($env:BAT_PATH); $m='# ===== POWERSHELL ====='; $i=$s.LastIndexOf($m); if($i -lt 0){Write-Host 'ERROR: powershell section not found'; exit 3}; $ps=$s.Substring($i+$m.Length); Invoke-Expression $ps"
if "%~1"=="" pause
exit /b

# ===== POWERSHELL =====
# 用法：
#   直接双击或在 cmd 里运行本脚本 -> 列出章节，交互选择
#   gen_quests.bat list            -> 只列出所有任务章节
#   gen_quests.bat "Feeding Yourself" -> 直接按名称提取
#   环境变量 BQ_BASE 可覆盖整合包主目录（默认脚本所在目录）
#   环境变量 BQ_OUT  可覆盖输出文件路径
$ErrorActionPreference = 'Stop'

$base = if ($env:BQ_BASE) { $env:BQ_BASE.TrimEnd('\') } else { $env:BAT_DIR.TrimEnd('\') }
$arg  = $env:ARG1
$outOverride = $env:BQ_OUT

$bqRoot = Join-Path $base 'config\betterquesting\DefaultQuests'
$qlDir  = Join-Path $bqRoot 'QuestLines'
$qDir   = Join-Path $bqRoot 'Quests'

if (-not (Test-Path -LiteralPath $bqRoot)) {
    Write-Host "[错误] 找不到目录：$bqRoot"
    Write-Host "请把脚本放到整合包主目录下运行，或用环境变量 BQ_BASE 指定主目录。"
    exit 2
}

function Get-BqProps([string]$path) {
    $raw = [IO.File]::ReadAllText($path)
    $obj = $raw | ConvertFrom-Json
    $p = $obj.'properties:10'
    if ($null -eq $p) { return $null }
    return $p.'betterquesting:10'
}

function To-LangValue($s) {
    if ($null -eq $s) { return '' }
    $s = $s -replace "`r`n", "`n" -replace "`r", "`n"
    $s = $s.Replace('%', '%%').Replace("`n", '%n')
    return $s
}

function Strip-Format($s) {
    if ($null -eq $s) { return '' }
    return ($s -replace '\u00a7.', '') -replace '\u00a7', ''
}

# 列出全部任务章节（QuestLines）
$questlines = @()
if (Test-Path -LiteralPath $qlDir) {
    Get-ChildItem -LiteralPath $qlDir -Directory | ForEach-Object {
        $d = $_
        $code24 = $d.Name.Substring([Math]::Max(0, $d.Name.Length - 24))
        $code = $code24 -replace '=+$', ''
        $name = $code
        $desc = ''
        $qlj = Join-Path $d.FullName 'QuestLine.json'
        if (Test-Path -LiteralPath $qlj) {
            try {
                $props = Get-BqProps $qlj
                if ($props) {
                    $name = [string]$props.'name:8'
                    $desc = [string]$props.'desc:8'
                }
            } catch {
                $name = $code
            }
        }
        $questlines += [pscustomobject]@{ Name = $name; Desc = $desc; Code = $code; DirName = $d.Name; Dir = $d.FullName }
    }
}
$questlines = @($questlines | Sort-Object Code)

if ($arg -in @('list', '--list', '-list', 'ls')) {
    Write-Host "共 $($questlines.Count) 个任务章节："
    for ($i = 0; $i -lt $questlines.Count; $i++) {
        Write-Host ("  [{0,2}] {1}  ({2})" -f ($i + 1), $questlines[$i].Name, $questlines[$i].Code)
    }
    exit 0
}

# 确定目标章节
$target = $null
$query = $arg
if (-not $query) {
    Write-Host "共 $($questlines.Count) 个任务章节："
    for ($i = 0; $i -lt $questlines.Count; $i++) {
        Write-Host ("  [{0,2}] {1}  ({2})" -f ($i + 1), $questlines[$i].Name, $questlines[$i].Code)
    }
    Write-Host ''
    $query = Read-Host '请输入章节名称或序号'
    if (-not $query) { Write-Host '[错误] 未输入任何内容'; exit 1 }
}

if ($query -match '^\d+$') {
    $idx = [int]$query - 1
    if ($idx -ge 0 -and $idx -lt $questlines.Count) { $target = $questlines[$idx] }
} else {
    $target = $questlines | Where-Object { $_.Name -eq $query -or $_.Code -eq $query -or $_.DirName -eq $query } | Select-Object -First 1
}

if ($null -eq $target) {
    Write-Host "[错误] 未找到匹配的任务章节：$query"
    exit 1
}

# 找到对应任务目录
$targetQDir = $null
if (Test-Path -LiteralPath $qDir) {
    Get-ChildItem -LiteralPath $qDir -Directory | ForEach-Object {
        $d = $_
        $code24 = $d.Name.Substring([Math]::Max(0, $d.Name.Length - 24))
        if (($code24 -replace '=+$', '') -eq $target.Code) { $targetQDir = $d.FullName }
    }
}
if ($null -eq $targetQDir -or -not (Test-Path -LiteralPath $targetQDir)) {
    Write-Host "[错误] 找不到任务目录：Quests\$($target.DirName)"
    exit 1
}

# 提取子任务
$quests = @()
Get-ChildItem -LiteralPath $targetQDir -Filter *.json | ForEach-Object {
    $f = $_
    $baseName = [IO.Path]::GetFileNameWithoutExtension($f.Name)
    $code24 = $baseName.Substring([Math]::Max(0, $baseName.Length - 24))
    $code = $code24 -replace '=+$', ''
    $name = ''; $desc = ''
    try {
        $props = Get-BqProps $f.FullName
        if ($props) {
            $name = [string]$props.'name:8'
            $desc = [string]$props.'desc:8'
        }
    } catch {
        Write-Host ("[警告] 无法解析 {0}：{1}" -f $f.Name, $_.Exception.Message)
    }
    $quests += [pscustomobject]@{ Name = $name; Desc = $desc; Code = $code }
}

# 按任务代码字节序（ordinal）排序，与官方汉化一致
$sorted = @($quests)
for ($i = 0; $i -lt $sorted.Count; $i++) {
    for ($j = $i + 1; $j -lt $sorted.Count; $j++) {
        if ([string]::CompareOrdinal($sorted[$i].Code, $sorted[$j].Code) -gt 0) {
            $t = $sorted[$i]; $sorted[$i] = $sorted[$j]; $sorted[$j] = $t
        }
    }
}

# 组装输出（与 zh_CN.lang 章节格式一致）
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('## Quest Line: ' + (Strip-Format $target.Name))
[void]$sb.AppendLine('betterquesting.questline.' + $target.Code + '.name=' + (To-LangValue $target.Name))
[void]$sb.AppendLine('betterquesting.questline.' + $target.Code + '.desc=' + (To-LangValue $target.Desc))
[void]$sb.AppendLine('')
foreach ($q in $sorted) {
    [void]$sb.AppendLine('# Quest: ' + (Strip-Format $q.Name))
    [void]$sb.AppendLine('betterquesting.quest.' + $q.Code + '.name=' + (To-LangValue $q.Name))
    [void]$sb.AppendLine('betterquesting.quest.' + $q.Code + '.desc=' + (To-LangValue $q.Desc))
    [void]$sb.AppendLine('')
}
$content = ($sb.ToString() -replace "`r`n", "`n").TrimEnd("`r", "`n") + "`n"

# 输出文件
$safeName = (Strip-Format $target.Name) -replace '[\\/:*?"<>|]', '_'
$outFile = if ($outOverride) { $outOverride } else { Join-Path $base ($safeName + '.txt') }
[IO.File]::WriteAllText($outFile, $content, (New-Object System.Text.UTF8Encoding($false)))

Write-Host '完成！'
Write-Host ("  章节：{0}  ({1})" -f $target.Name, $target.Code)
Write-Host ("  任务数：{0}" -f $sorted.Count)
Write-Host ("  输出文件：{0}" -f $outFile)
