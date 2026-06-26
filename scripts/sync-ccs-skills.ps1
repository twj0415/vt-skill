param(
  [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$TargetRoot = "$env:USERPROFILE\.cc-switch\skills",
  [string[]]$TargetRoots = @(
    "$env:USERPROFILE\.cc-switch\skills",
    "$env:USERPROFILE\.codex\skills",
    "$env:USERPROFILE\.agents\skills",
    "$env:USERPROFILE\.claude\skills"
  ),
  [switch]$ReplaceExisting,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Step {
  param([string]$Message)
  Write-Host "[sync] $Message"
}

function Get-FullPath {
  param([string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

$sourceRootFull = Get-FullPath $SourceRoot

if ($PSBoundParameters.ContainsKey("TargetRoot")) {
  $TargetRoots = @($TargetRoot)
}

$targetRootFullList = $TargetRoots |
  ForEach-Object { Get-FullPath $_ } |
  Select-Object -Unique

if (-not (Test-Path -LiteralPath $sourceRootFull -PathType Container)) {
  throw "SourceRoot does not exist: $sourceRootFull"
}

$skills = Get-ChildItem -LiteralPath $sourceRootFull -Directory -Force |
  Where-Object {
    $_.Name -ne ".git" -and
    $_.Name -ne "scripts" -and
    (Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf)
  }

if (-not $skills) {
  Write-Step "No skill directories found under $sourceRootFull"
  exit 0
}

foreach ($targetRootFull in $targetRootFullList) {
  Write-Step "Target root: $targetRootFull"

  if (-not (Test-Path -LiteralPath $targetRootFull -PathType Container)) {
    if ($DryRun) {
      Write-Step "Would create target root: $targetRootFull"
    } else {
      New-Item -ItemType Directory -Path $targetRootFull | Out-Null
      Write-Step "Created target root: $targetRootFull"
    }
  }

  foreach ($skill in $skills) {
    $source = Get-FullPath $skill.FullName
    $target = Join-Path $targetRootFull $skill.Name
    $targetExists = Test-Path -LiteralPath $target

    if (-not $targetExists) {
      if ($DryRun) {
        Write-Step "Would link $target -> $source"
      } else {
        New-Item -ItemType Junction -Path $target -Target $source | Out-Null
        Write-Step "Linked $target -> $source"
      }
      continue
    }

    $targetItem = Get-Item -LiteralPath $target -Force
    if ($targetItem.LinkType -in @("Junction", "SymbolicLink")) {
      $currentTarget = $targetItem.Target
      if ($currentTarget -eq $source) {
        Write-Step "Already linked: $target"
        continue
      }

      if ($DryRun) {
        Write-Step "Would replace existing link $target from $currentTarget to $source"
      } else {
        Remove-Item -LiteralPath $target -Force
        New-Item -ItemType Junction -Path $target -Target $source | Out-Null
        Write-Step "Re-linked $target -> $source"
      }
      continue
    }

    if (-not $ReplaceExisting) {
      Write-Step "Skipped existing normal directory: $target"
      Write-Step "Run with -ReplaceExisting to back it up and replace it with a junction."
      continue
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backup = "$target.backup.$timestamp"

    if ($DryRun) {
      Write-Step "Would move $target to $backup"
      Write-Step "Would link $target -> $source"
    } else {
      Move-Item -LiteralPath $target -Destination $backup
      New-Item -ItemType Junction -Path $target -Target $source | Out-Null
      Write-Step "Backed up $target to $backup"
      Write-Step "Linked $target -> $source"
    }
  }
}

Write-Step "Done."
