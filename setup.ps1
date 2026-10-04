# Taurs setup starter for Windows. Run in PowerShell:
#
#   irm https://raw.githubusercontent.com/seemantmsingh/taurs-setup/main/setup.ps1 | iex
#
# It installs Git and the GitHub CLI, signs in to GitHub (the Taurs repository is private),
# then downloads and runs the full setup, scripts/onboard-windows.ps1, from that repository.
# This file holds no secrets and no Taurs code.
& {
  $ErrorActionPreference = 'Stop'
  $repository = 'seemantmsingh/taurs'
  $setupPath = 'scripts/onboard-windows.ps1'

  function Update-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
  }

  function Install-Tool([string]$command, [string]$package) {
    if (Get-Command $command -ErrorAction SilentlyContinue) { return }
    Write-Host "  Installing $package..."
    winget install --id $package --exact --silent --accept-package-agreements --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Installing $package failed." }
    Update-SessionPath
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "$command is not on PATH after installing $package." }
  }

  # gh writes "not logged in" to stderr; cmd keeps that away from PowerShell's error handling.
  function Test-GitHubSignIn {
    cmd.exe /d /c 'gh auth status >nul 2>&1'
    return $LASTEXITCODE -eq 0
  }

  Write-Host ''
  Write-Host ("  $([char]0x25C8) Taurs setup") -ForegroundColor Cyan
  Write-Host '  Preparing: Git, the GitHub CLI, and a GitHub sign-in.' -ForegroundColor DarkGray
  Write-Host ''
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'winget is missing; install App Installer from the Microsoft Store.' }
  Install-Tool 'git' 'Git.Git'
  Install-Tool 'gh' 'GitHub.cli'
  if (-not (Test-GitHubSignIn)) {
    Write-Host '  A browser window opens: sign in to GitHub and enter the code shown here.' -ForegroundColor Cyan
    gh auth login --hostname github.com --git-protocol https --web
    if (-not (Test-GitHubSignIn)) { throw 'GitHub sign-in did not complete.' }
  }

  $setup = Join-Path $env:TEMP 'taurs-setup.ps1'
  cmd.exe /d /c "gh api repos/$repository/contents/$setupPath -H ""Accept: application/vnd.github.raw"" > ""$setup"""
  if ($LASTEXITCODE -ne 0) { throw "Downloading the setup failed; check that your GitHub account can read $repository." }
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File $setup
}
