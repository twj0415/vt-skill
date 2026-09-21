[CmdletBinding()]
param(
  [string]$ConfigPath,
  [string]$Period,
  [string]$Start,
  [string]$End,
  [ValidateRange(1, 3650)]
  [int]$Days = 7,
  [string[]]$Project,
  [string]$RepositoryPath,
  [string]$ProjectName = '当前项目',
  [string[]]$IncludePath,
  [switch]$IncludeUncommitted
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'config\周报配置.json'
}

function Get-ConfigProperty {
  param(
    [Parameter(Mandatory)]$Object,
    [Parameter(Mandatory)][string]$Name,
    $Default = $null
  )

  $property = $Object.PSObject.Properties[$Name]
  if ($null -eq $property -or $null -eq $property.Value) {
    return $Default
  }
  return $property.Value
}

function Resolve-ConfiguredPath {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$BaseDirectory
  )

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path))
}

function Resolve-TimeZoneInfo {
  param([string]$Id)

  $candidates = [System.Collections.Generic.List[string]]::new()
  if (-not [string]::IsNullOrWhiteSpace($Id)) {
    $candidates.Add($Id)
  }
  if ($Id -eq 'Asia/Shanghai') {
    $candidates.Add('China Standard Time')
  }

  foreach ($candidate in $candidates) {
    try {
      return [System.TimeZoneInfo]::FindSystemTimeZoneById($candidate)
    }
    catch {
      continue
    }
  }
  throw "无法识别时区：$Id"
}

function New-ZonedDateTimeOffset {
  param(
    [Parameter(Mandatory)][datetime]$LocalDateTime,
    [Parameter(Mandatory)][System.TimeZoneInfo]$TimeZone
  )

  $unspecified = [datetime]::SpecifyKind($LocalDateTime, [DateTimeKind]::Unspecified)
  if ($TimeZone.IsInvalidTime($unspecified)) {
    throw "时间位于无效的夏令时区间：$LocalDateTime"
  }
  return [datetimeoffset]::new($unspecified, $TimeZone.GetUtcOffset($unspecified))
}

function Parse-LocalDateTime {
  param(
    [Parameter(Mandatory)][string]$Value,
    [switch]$EndBoundary
  )

  $culture = [System.Globalization.CultureInfo]::InvariantCulture
  $styles = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces
  $parsed = [datetime]::Parse($Value, $culture, $styles)
  if ($EndBoundary -and $Value.Trim() -match '^\d{4}-\d{1,2}-\d{1,2}$') {
    return $parsed.Date.AddDays(1)
  }
  return $parsed
}

function Get-WeekMonday {
  param([Parameter(Mandatory)][datetime]$Date)

  $daysFromMonday = (([int]$Date.DayOfWeek + 6) % 7)
  return $Date.Date.AddDays(-$daysFromMonday)
}

function Resolve-TimeRange {
  param(
    [string]$PeriodValue,
    [string]$StartValue,
    [string]$EndValue,
    [int]$RecentDays,
    [Parameter(Mandatory)][System.TimeZoneInfo]$TimeZone,
    [string]$DefaultPeriod
  )

  $now = [System.TimeZoneInfo]::ConvertTime([datetimeoffset]::UtcNow, $TimeZone)
  $nowLocal = $now.DateTime

  if (-not [string]::IsNullOrWhiteSpace($StartValue)) {
    $startLocal = Parse-LocalDateTime -Value $StartValue
    $endLocal = if ([string]::IsNullOrWhiteSpace($EndValue)) {
      $nowLocal
    }
    else {
      Parse-LocalDateTime -Value $EndValue -EndBoundary
    }
    if ($endLocal -le $startLocal) {
      throw '结束时间必须晚于开始时间。'
    }
    $endLabel = if ([string]::IsNullOrWhiteSpace($EndValue)) { '当前时间' } else { $EndValue }
    return [pscustomobject]@{
      Label = "自定义：$StartValue 至 $endLabel"
      Start = New-ZonedDateTimeOffset -LocalDateTime $startLocal -TimeZone $TimeZone
      End = New-ZonedDateTimeOffset -LocalDateTime $endLocal -TimeZone $TimeZone
    }
  }
  if (-not [string]::IsNullOrWhiteSpace($EndValue)) {
    throw '使用 -End 时必须同时提供 -Start。'
  }

  $normalized = if ([string]::IsNullOrWhiteSpace($PeriodValue)) { $DefaultPeriod } else { $PeriodValue }
  if ([string]::IsNullOrWhiteSpace($normalized)) {
    $normalized = '上周'
  }
  $normalized = $normalized.Trim().ToLowerInvariant() -replace '\s+', ''

  $startLocal = $null
  $endLocal = $null
  $label = $normalized

  switch -Regex ($normalized) {
    '^(今天|today)$' {
      $startLocal = $nowLocal.Date
      $endLocal = $nowLocal
      $label = '今天'
      break
    }
    '^(昨天|yesterday)$' {
      $startLocal = $nowLocal.Date.AddDays(-1)
      $endLocal = $nowLocal.Date
      $label = '昨天'
      break
    }
    '^(本周|这周|current-week|this-week)$' {
      $startLocal = Get-WeekMonday -Date $nowLocal
      $endLocal = $nowLocal
      $label = '本周'
      break
    }
    '^(上周|上一周|last-week|previous-week)$' {
      $endLocal = Get-WeekMonday -Date $nowLocal
      $startLocal = $endLocal.AddDays(-7)
      $label = '上周'
      break
    }
    '^(本月|current-month|this-month)$' {
      $startLocal = [datetime]::new($nowLocal.Year, $nowLocal.Month, 1)
      $endLocal = $nowLocal
      $label = '本月'
      break
    }
    '^(上月|last-month|previous-month)$' {
      $endLocal = [datetime]::new($nowLocal.Year, $nowLocal.Month, 1)
      $startLocal = $endLocal.AddMonths(-1)
      $label = '上月'
      break
    }
    '^最近(\d+)天$' {
      $resolvedDays = [int]$Matches[1]
      $startLocal = $nowLocal.AddDays(-$resolvedDays)
      $endLocal = $nowLocal
      $label = "最近${resolvedDays}天"
      break
    }
    '^recent-(\d+)-days$' {
      $resolvedDays = [int]$Matches[1]
      $startLocal = $nowLocal.AddDays(-$resolvedDays)
      $endLocal = $nowLocal
      $label = "最近${resolvedDays}天"
      break
    }
    '^(最近n天|recent-days)$' {
      $startLocal = $nowLocal.AddDays(-$RecentDays)
      $endLocal = $nowLocal
      $label = "最近${RecentDays}天"
      break
    }
    '^(\d{4})[-年](\d{1,2})月?$' {
      $year = [int]$Matches[1]
      $month = [int]$Matches[2]
      $startLocal = [datetime]::new($year, $month, 1)
      $endLocal = $startLocal.AddMonths(1)
      $label = "${year}年${month}月"
      break
    }
    '^(\d{4})年第?(\d{1,2})周$' {
      $year = [int]$Matches[1]
      $week = [int]$Matches[2]
      if ($week -lt 1 -or $week -gt 53) {
        throw "无效的自然周：$normalized"
      }
      $january4 = [datetime]::new($year, 1, 4)
      $weekOneMonday = Get-WeekMonday -Date $january4
      $startLocal = $weekOneMonday.AddDays(($week - 1) * 7)
      $endLocal = $startLocal.AddDays(7)
      $label = "${year}年第${week}周"
      break
    }
    default {
      throw "不支持的统计范围：$normalized"
    }
  }

  return [pscustomobject]@{
    Label = $label
    Start = New-ZonedDateTimeOffset -LocalDateTime $startLocal -TimeZone $TimeZone
    End = New-ZonedDateTimeOffset -LocalDateTime $endLocal -TimeZone $TimeZone
  }
}

function Invoke-Git {
  param(
    [Parameter(Mandatory)][string]$Repository,
    [Parameter(Mandatory)][string[]]$Arguments,
    [switch]$AllowFailure
  )

  $gitArguments = @('-C', $Repository) + $Arguments
  $output = @(& git @gitArguments 2>&1)
  $exitCode = $LASTEXITCODE
  $lines = @($output | ForEach-Object { [string]$_ })
  if ($exitCode -ne 0 -and -not $AllowFailure) {
    throw (($lines -join "`n").Trim())
  }
  return [pscustomobject]@{
    ExitCode = $exitCode
    Lines = $lines
  }
}

function Get-Pathspec {
  param($ProjectConfig)

  $includes = @(Get-ConfigProperty -Object $ProjectConfig -Name '统计路径' -Default @())
  $excludes = @(Get-ConfigProperty -Object $ProjectConfig -Name '排除路径' -Default @())
  $pathspec = [System.Collections.Generic.List[string]]::new()
  foreach ($include in $includes) {
    if (-not [string]::IsNullOrWhiteSpace([string]$include)) {
      $pathspec.Add([string]$include)
    }
  }
  if ($pathspec.Count -eq 0 -and $excludes.Count -gt 0) {
    $pathspec.Add('.')
  }
  foreach ($exclude in $excludes) {
    if (-not [string]::IsNullOrWhiteSpace([string]$exclude)) {
      $pathspec.Add(":(exclude)$exclude")
    }
  }
  return $pathspec.ToArray()
}

function Get-RefArguments {
  param($ProjectConfig)

  $scope = [string](Get-ConfigProperty -Object $ProjectConfig -Name '分支范围' -Default '全部本地分支')
  switch ($scope) {
    '当前分支' { return @('HEAD') }
    '主分支' {
      $mainBranch = [string](Get-ConfigProperty -Object $ProjectConfig -Name '主分支' -Default 'HEAD')
      return @($mainBranch)
    }
    '指定分支' {
      $branches = @(Get-ConfigProperty -Object $ProjectConfig -Name '分支列表' -Default @())
      if ($branches.Count -eq 0) {
        throw '分支范围为“指定分支”时必须配置“分支列表”。'
      }
      return @($branches | ForEach-Object { [string]$_ })
    }
    default { return @('--branches') }
  }
}

function Get-CommitStats {
  param(
    [Parameter(Mandatory)][string]$Repository,
    [Parameter(Mandatory)][string]$Hash,
    [string[]]$Pathspec
  )

  $arguments = @('show', '--numstat', '--format=', '--find-renames', $Hash)
  if ($Pathspec.Count -gt 0) {
    $arguments += '--'
    $arguments += $Pathspec
  }
  $result = Invoke-Git -Repository $Repository -Arguments $arguments
  $files = [System.Collections.Generic.List[object]]::new()
  $addedTotal = 0
  $deletedTotal = 0

  foreach ($line in $result.Lines) {
    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }
    $parts = $line -split "`t", 3
    if ($parts.Count -ne 3) {
      continue
    }
    $binary = $parts[0] -eq '-' -or $parts[1] -eq '-'
    $added = if ($binary) { $null } else { [int]$parts[0] }
    $deleted = if ($binary) { $null } else { [int]$parts[1] }
    if (-not $binary) {
      $addedTotal += $added
      $deletedTotal += $deleted
    }
    $files.Add([pscustomobject]@{
      路径 = $parts[2]
      新增行 = $added
      删除行 = $deleted
      二进制 = $binary
    })
  }

  return [pscustomobject]@{
    文件 = $files.ToArray()
    文件数 = $files.Count
    新增行 = $addedTotal
    删除行 = $deletedTotal
  }
}

function Get-StablePatchId {
  param(
    [Parameter(Mandatory)][string]$Repository,
    [Parameter(Mandatory)][string]$Hash,
    [string[]]$Pathspec,
    [bool]$IsMerge
  )

  if ($IsMerge) {
    return $null
  }
  $arguments = @('show', '--pretty=format:', '--no-ext-diff', '--binary', $Hash)
  if ($Pathspec.Count -gt 0) {
    $arguments += '--'
    $arguments += $Pathspec
  }
  $diff = Invoke-Git -Repository $Repository -Arguments $arguments
  if ($diff.Lines.Count -eq 0) {
    return $null
  }

  $patchOutput = @(($diff.Lines -join "`n") | & git patch-id --stable 2>&1)
  if ($LASTEXITCODE -ne 0 -or $patchOutput.Count -eq 0) {
    return $null
  }
  $firstLine = [string]$patchOutput[0]
  if ($firstLine -match '^([0-9a-f]{40})\s') {
    return $Matches[1]
  }
  return $null
}

function Test-MergedIntoBranch {
  param(
    [Parameter(Mandatory)][string]$Repository,
    [Parameter(Mandatory)][string]$Hash,
    [string]$MainBranch
  )

  if ([string]::IsNullOrWhiteSpace($MainBranch)) {
    return $null
  }
  $result = Invoke-Git -Repository $Repository -Arguments @('merge-base', '--is-ancestor', $Hash, $MainBranch) -AllowFailure
  if ($result.ExitCode -eq 0) {
    return $true
  }
  if ($result.ExitCode -eq 1) {
    return $false
  }
  return $null
}

function Get-OwnershipType {
  param(
    [Parameter(Mandatory)][string]$AuthorName,
    [Parameter(Mandatory)][string]$AuthorEmail,
    [string]$Body,
    [string[]]$Emails,
    [string[]]$Names,
    [bool]$AllowNameFallback
  )

  $normalizedEmail = $AuthorEmail.Trim().ToLowerInvariant()
  if ($Emails -contains $normalizedEmail) {
    return '作者'
  }

  if (-not [string]::IsNullOrWhiteSpace($Body)) {
    $coAuthors = [regex]::Matches($Body, '(?im)^Co-authored-by:\s*.*?<([^>]+)>')
    foreach ($match in $coAuthors) {
      if ($Emails -contains $match.Groups[1].Value.Trim().ToLowerInvariant()) {
        return '共同作者'
      }
    }
  }

  if ($AllowNameFallback -and $Names -contains $AuthorName.Trim()) {
    return '作者姓名匹配'
  }
  return $null
}

function Get-ProjectResult {
  param(
    [Parameter(Mandatory)]$ProjectConfig,
    [Parameter(Mandatory)]$GlobalIdentity,
    [Parameter(Mandatory)]$Range,
    [Parameter(Mandatory)][string]$ConfigDirectory,
    [bool]$CollectUncommitted
  )

  $projectId = [string](Get-ConfigProperty -Object $ProjectConfig -Name '项目编号' -Default 'unknown')
  $projectNameValue = [string](Get-ConfigProperty -Object $ProjectConfig -Name '项目名称' -Default $projectId)
  $warnings = [System.Collections.Generic.List[string]]::new()
  $repositoryValue = [string](Get-ConfigProperty -Object $ProjectConfig -Name '仓库路径')

  try {
    if ([string]::IsNullOrWhiteSpace($repositoryValue)) {
      throw '未配置仓库路径。'
    }
    $repository = Resolve-ConfiguredPath -Path $repositoryValue -BaseDirectory $ConfigDirectory
    if (-not (Test-Path -LiteralPath $repository -PathType Container)) {
      throw "仓库路径不存在：$repository"
    }

    $insideWorkTree = Invoke-Git -Repository $repository -Arguments @('rev-parse', '--is-inside-work-tree')
    if (($insideWorkTree.Lines -join '').Trim() -ne 'true') {
      throw '目标路径不是 Git 工作树。'
    }
    $repositoryRoot = ((Invoke-Git -Repository $repository -Arguments @('rev-parse', '--show-toplevel')).Lines -join '').Trim()
    $shallow = ((Invoke-Git -Repository $repository -Arguments @('rev-parse', '--is-shallow-repository') -AllowFailure).Lines -join '').Trim()
    if ($shallow -eq 'true') {
      $warnings.Add('仓库是浅克隆，历史提交可能不完整。')
    }

    $pathspec = @(Get-Pathspec -ProjectConfig $ProjectConfig)
    $refArguments = @(Get-RefArguments -ProjectConfig $ProjectConfig)
    $mainBranch = [string](Get-ConfigProperty -Object $ProjectConfig -Name '主分支' -Default '')
    if (-not [string]::IsNullOrWhiteSpace($mainBranch)) {
      $verifyMain = Invoke-Git -Repository $repositoryRoot -Arguments @('rev-parse', '--verify', $mainBranch) -AllowFailure
      if ($verifyMain.ExitCode -ne 0) {
        $warnings.Add("主分支不存在或不可解析：$mainBranch")
        $mainBranch = ''
      }
    }

    $overrideEmails = @(Get-ConfigProperty -Object $ProjectConfig -Name '作者邮箱覆盖' -Default @())
    $sourceEmails = if ($overrideEmails.Count -gt 0) { $overrideEmails } else { @(Get-ConfigProperty -Object $GlobalIdentity -Name '邮箱' -Default @()) }
    $emails = @($sourceEmails | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() } | Where-Object { $_ } | Select-Object -Unique)
    $names = @((Get-ConfigProperty -Object $GlobalIdentity -Name '姓名' -Default @()) | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ } | Select-Object -Unique)
    $allowNameFallback = [bool](Get-ConfigProperty -Object $GlobalIdentity -Name '允许姓名兜底' -Default $false)
    if ($emails.Count -eq 0 -and -not $allowNameFallback) {
      throw '没有配置作者邮箱，且未允许姓名兜底，无法可靠识别提交归属。'
    }

    $fieldSeparator = [char]0x1f
    $recordSeparator = [char]0x1e
    $format = '%H%x1f%h%x1f%an%x1f%ae%x1f%cn%x1f%ce%x1f%aI%x1f%P%x1f%s%x1f%b%x1e'
    $logArguments = @('log') + $refArguments + @(
      "--since=$($Range.Start.ToString('yyyy-MM-ddTHH:mm:sszzz'))",
      "--until=$($Range.End.ToString('yyyy-MM-ddTHH:mm:sszzz'))",
      "--pretty=format:$format",
      '--no-color'
    )
    if ($pathspec.Count -gt 0) {
      $logArguments += '--'
      $logArguments += $pathspec
    }
    $log = Invoke-Git -Repository $repositoryRoot -Arguments $logArguments
    $rawLog = $log.Lines -join "`n"
    $records = @($rawLog -split [regex]::Escape([string]$recordSeparator))

    $commits = [System.Collections.Generic.List[object]]::new()
    $otherAuthors = @{}
    foreach ($recordValue in $records) {
      $record = $recordValue.Trim([char[]]"`r`n")
      if ([string]::IsNullOrWhiteSpace($record)) {
        continue
      }
      $fields = @($record -split [regex]::Escape([string]$fieldSeparator))
      if ($fields.Count -lt 10) {
        $warnings.Add('发现无法解析的提交记录，已跳过并标记统计可能不完整。')
        continue
      }

      $hash = $fields[0].Trim()
      $shortHash = $fields[1].Trim()
      $authorName = $fields[2].Trim()
      $authorEmail = $fields[3].Trim()
      $committerName = $fields[4].Trim()
      $committerEmail = $fields[5].Trim()
      $authorDate = $fields[6].Trim()
      $parents = @($fields[7].Trim() -split '\s+' | Where-Object { $_ })
      $subject = $fields[8].Trim()
      $body = (($fields[9..($fields.Count - 1)] -join [string]$fieldSeparator).Trim())
      $ownership = Get-OwnershipType -AuthorName $authorName -AuthorEmail $authorEmail -Body $body -Emails $emails -Names $names -AllowNameFallback $allowNameFallback
      if ($null -eq $ownership) {
        $authorKey = if ($authorEmail) { "$authorName <$($authorEmail.ToLowerInvariant())>" } else { $authorName }
        if (-not $otherAuthors.ContainsKey($authorKey)) {
          $otherAuthors[$authorKey] = 0
        }
        $otherAuthors[$authorKey]++
        continue
      }

      $isMerge = $parents.Count -gt 1
      $stats = Get-CommitStats -Repository $repositoryRoot -Hash $hash -Pathspec $pathspec
      $patchId = Get-StablePatchId -Repository $repositoryRoot -Hash $hash -Pathspec $pathspec -IsMerge $isMerge
      $mergedIntoMain = Test-MergedIntoBranch -Repository $repositoryRoot -Hash $hash -MainBranch $mainBranch
      $commits.Add([pscustomobject]@{
        哈希 = $hash
        短哈希 = $shortHash
        作者 = $authorName
        作者邮箱 = $authorEmail
        提交者 = $committerName
        提交者邮箱 = $committerEmail
        作者时间 = $authorDate
        标题 = $subject
        正文 = $body
        父提交 = $parents
        合并提交 = $isMerge
        归属类型 = $ownership
        已合入主分支 = $mergedIntoMain
        稳定补丁编号 = $patchId
        文件数 = $stats.文件数
        新增行 = $stats.新增行
        删除行 = $stats.删除行
        文件 = $stats.文件
        计入去重后工作 = $true
        重复于 = $null
        重复提交哈希 = @()
      })
    }

    $duplicateGroups = [System.Collections.Generic.List[object]]::new()
    $patchGroups = @($commits | Where-Object { $_.稳定补丁编号 } | Group-Object -Property 稳定补丁编号)
    foreach ($group in $patchGroups) {
      if ($group.Count -lt 2) {
        continue
      }
      $ordered = @($group.Group | Sort-Object -Property 作者时间, 哈希)
      $primary = $ordered[0]
      $duplicates = @($ordered | Select-Object -Skip 1)
      $primary.重复提交哈希 = @($duplicates | ForEach-Object { $_.哈希 })
      foreach ($duplicate in $duplicates) {
        $duplicate.计入去重后工作 = $false
        $duplicate.重复于 = $primary.哈希
      }
      $duplicateGroups.Add([pscustomobject]@{
        稳定补丁编号 = $group.Name
        保留提交 = $primary.哈希
        重复提交 = @($duplicates | ForEach-Object { $_.哈希 })
      })
    }

    $uncommitted = @()
    if ($CollectUncommitted) {
      $statusArguments = @('status', '--short', '--untracked-files=normal')
      if ($pathspec.Count -gt 0) {
        $statusArguments += '--'
        $statusArguments += $pathspec
      }
      $uncommitted = @((Invoke-Git -Repository $repositoryRoot -Arguments $statusArguments).Lines)
    }

    $otherAuthorSummary = @($otherAuthors.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
      [pscustomobject]@{ 作者 = $_.Name; 提交数 = $_.Value }
    })
    $uniqueFiles = @($commits | ForEach-Object { $_.文件 } | ForEach-Object { $_.路径 } | Sort-Object -Unique)

    return [pscustomobject]@{
      项目编号 = $projectId
      项目名称 = $projectNameValue
      项目排序 = [int](Get-ConfigProperty -Object $ProjectConfig -Name '项目排序' -Default 9999)
      状态 = '成功'
      仓库根目录 = $repositoryRoot
      统计路径 = $pathspec
      主分支 = $mainBranch
      警告 = $warnings.ToArray()
      其他作者摘要 = $otherAuthorSummary
      提交数 = $commits.Count
      去重后提交数 = @($commits | Where-Object { $_.计入去重后工作 }).Count
      唯一文件数 = $uniqueFiles.Count
      新增行 = ($commits | Measure-Object -Property 新增行 -Sum).Sum
      删除行 = ($commits | Measure-Object -Property 删除行 -Sum).Sum
      重复提交组 = $duplicateGroups.ToArray()
      提交 = $commits.ToArray()
      未提交工作 = $uncommitted
    }
  }
  catch {
    return [pscustomobject]@{
      项目编号 = $projectId
      项目名称 = $projectNameValue
      项目排序 = [int](Get-ConfigProperty -Object $ProjectConfig -Name '项目排序' -Default 9999)
      状态 = '失败'
      仓库根目录 = $repositoryValue
      统计路径 = @(Get-ConfigProperty -Object $ProjectConfig -Name '统计路径' -Default @())
      主分支 = [string](Get-ConfigProperty -Object $ProjectConfig -Name '主分支' -Default '')
      警告 = @($_.Exception.Message)
      其他作者摘要 = @()
      提交数 = 0
      去重后提交数 = 0
      唯一文件数 = 0
      新增行 = 0
      删除行 = 0
      重复提交组 = @()
      提交 = @()
      未提交工作 = @()
    }
  }
}

if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
  throw '未找到 git 命令。'
}

$resolvedConfigPath = (Resolve-Path -LiteralPath $ConfigPath).Path
$configDirectory = Split-Path $resolvedConfigPath -Parent
$config = Get-Content -LiteralPath $resolvedConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([int](Get-ConfigProperty -Object $config -Name '配置版本' -Default 0) -ne 1) {
  throw '不支持的配置版本。当前脚本只支持配置版本 1。'
}

$timeZoneId = [string](Get-ConfigProperty -Object $config -Name '时区' -Default 'Asia/Shanghai')
$timeZone = Resolve-TimeZoneInfo -Id $timeZoneId
$range = Resolve-TimeRange -PeriodValue $Period -StartValue $Start -EndValue $End -RecentDays $Days -TimeZone $timeZone -DefaultPeriod ([string](Get-ConfigProperty -Object $config -Name '默认统计范围' -Default '上周'))
$identity = Get-ConfigProperty -Object $config -Name '我的身份'
if ($null -eq $identity) {
  throw '配置中缺少“我的身份”。'
}

if (-not [string]::IsNullOrWhiteSpace($RepositoryPath)) {
  $projects = @([pscustomobject]@{
    启用 = $true
    项目编号 = 'temporary-current-project'
    项目名称 = $ProjectName
    仓库路径 = $RepositoryPath
    统计路径 = @($IncludePath)
    排除路径 = @()
    主分支 = 'HEAD'
    分支范围 = '全部本地分支'
    项目排序 = 1
  })
}
else {
  $projects = @(Get-ConfigProperty -Object $config -Name '项目列表' -Default @() | Where-Object {
    (Get-ConfigProperty -Object $_ -Name '启用' -Default $true) -ne $false
  })
}

if ($null -ne $Project -and $Project.Count -gt 0) {
  $requestedProjects = @($Project | ForEach-Object { $_.Trim().ToLowerInvariant() })
  $projects = @($projects | Where-Object {
    $id = ([string](Get-ConfigProperty -Object $_ -Name '项目编号' -Default '')).ToLowerInvariant()
    $name = ([string](Get-ConfigProperty -Object $_ -Name '项目名称' -Default '')).ToLowerInvariant()
    $requestedProjects -contains $id -or $requestedProjects -contains $name
  })
}
if ($projects.Count -eq 0) {
  throw '没有找到符合条件的项目。'
}

$reportSettings = Get-ConfigProperty -Object $config -Name '报告设置' -Default ([pscustomobject]@{})
$collectUncommitted = $IncludeUncommitted.IsPresent -or [bool](Get-ConfigProperty -Object $reportSettings -Name '包含未提交工作' -Default $false)
$projectResults = [System.Collections.Generic.List[object]]::new()
foreach ($projectConfig in $projects) {
  $projectResults.Add((Get-ProjectResult -ProjectConfig $projectConfig -GlobalIdentity $identity -Range $range -ConfigDirectory $configDirectory -CollectUncommitted $collectUncommitted))
}
$orderedResults = @($projectResults | Sort-Object -Property 项目排序, 项目名称)

$globalCommitKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$globalWorkKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($projectResult in $orderedResults) {
  if ($projectResult.状态 -ne '成功') {
    continue
  }
  foreach ($commit in $projectResult.提交) {
    $repositoryKey = ([string]$projectResult.仓库根目录).ToLowerInvariant()
    [void]$globalCommitKeys.Add("$repositoryKey|$($commit.哈希)")
    if ($commit.计入去重后工作) {
      $workIdentity = if ($commit.稳定补丁编号) { $commit.稳定补丁编号 } else { $commit.哈希 }
      [void]$globalWorkKeys.Add("$repositoryKey|$workIdentity")
    }
  }
}

$failedProjects = @($orderedResults | Where-Object { $_.状态 -eq '失败' })
$report = [pscustomobject]@{
  数据格式版本 = 1
  生成时间 = ([System.TimeZoneInfo]::ConvertTime([datetimeoffset]::UtcNow, $timeZone)).ToString('yyyy-MM-ddTHH:mm:sszzz')
  时区 = $timeZoneId
  统计范围 = [pscustomobject]@{
    名称 = $range.Label
    开始 = $range.Start.ToString('yyyy-MM-ddTHH:mm:sszzz')
    结束 = $range.End.ToString('yyyy-MM-ddTHH:mm:sszzz')
    边界规则 = '左闭右开'
  }
  完整性 = [pscustomobject]@{
    状态 = if ($failedProjects.Count -eq 0) { '完整' } else { '不完整' }
    配置项目数 = $projects.Count
    成功项目数 = @($orderedResults | Where-Object { $_.状态 -eq '成功' }).Count
    失败项目数 = $failedProjects.Count
    属于用户的唯一提交数 = $globalCommitKeys.Count
    去重后唯一工作提交数 = $globalWorkKeys.Count
  }
  报告设置 = $reportSettings
  项目结果 = $orderedResults
}

$json = $report | ConvertTo-Json -Depth 20
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
Write-Output $json
