#!/usr/bin/env pwsh
# CC-Hippocampus - One-Click Installation from GitHub
# Usage: irm https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.ps1 | iex
# Or: powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.ps1 | iex"

param(
    [switch]$Force
)

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     CC-Hippocampus - One-Click Installation          ║" -ForegroundColor Cyan
Write-Host "║         (No git clone required!)                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Get Claude Code configuration directory
$claudeDir = "$env:USERPROFILE\.claude"
$pluginsDir = "$claudeDir\plugins"
$skillsDir = "$claudeDir\skills"
$hooksDir = "$claudeDir\hooks"

# GitHub raw URL
$githubRaw = "https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main"

Write-Host "[1/5] Creating directories..." -ForegroundColor Yellow

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
}
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

Write-Host "   ✓ Directories ready" -ForegroundColor Green
Write-Host ""

# Download plugin
Write-Host "[2/5] Downloading plugin from GitHub..." -ForegroundColor Yellow

$pluginName = "CC-Hippocampus"
$pluginDest = "$pluginsDir\$pluginName"

# Check if running in pipe mode
$IS_PIPE = $MyInvocation.ExpectingInput

if (Test-Path $pluginDest) {
    if ($Force) {
        Write-Host "   Removing existing installation..." -ForegroundColor Gray
        Remove-Item -Recurse -Force $pluginDest
    } elseif ($IS_PIPE) {
        Write-Host "   ⚠ Running in pipe mode. Plugin already exists at: $pluginDest" -ForegroundColor Yellow
        Write-Host "   Skipping installation. Use -Force to overwrite." -ForegroundColor Yellow
        Write-Host "   Example: irm https://.../install.ps1 | iex -Force" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "   ⚠ Plugin already installed at: $pluginDest" -ForegroundColor Yellow
        $response = Read-Host "   Overwrite? (y/n)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "   Installation cancelled." -ForegroundColor Red
            exit 1
        }
        Remove-Item -Recurse -Force $pluginDest
    }
}

New-Item -ItemType Directory -Force -Path "$pluginDest\tools" | Out-Null
New-Item -ItemType Directory -Force -Path "$pluginDest\rules" | Out-Null

# Download core files
Invoke-WebRequest -Uri "$githubRaw/tools/hippocampus.py" -OutFile "$pluginDest\tools\hippocampus.py"
Invoke-WebRequest -Uri "$githubRaw/rules/hippocampus_policy.md" -OutFile "$pluginDest\rules\hippocampus_policy.md"

Write-Host "   ✓ Plugin installed to: $pluginDest" -ForegroundColor Green
Write-Host ""

# Download skills
Write-Host "[3/5] Downloading skills..." -ForegroundColor Yellow

$skillsDest = "$skillsDir\hippocampus"
if (Test-Path $skillsDest) {
    if ($Force) {
        Remove-Item -Recurse -Force $skillsDest
    }
}
New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null

Invoke-WebRequest -Uri "$githubRaw/skills/hippocampus/SKILL.md" -OutFile "$skillsDest\SKILL.md"
Invoke-WebRequest -Uri "$githubRaw/skills/hippocampus/load.js" -OutFile "$skillsDest\load.js"
Invoke-WebRequest -Uri "$githubRaw/skills/hippocampus/save.js" -OutFile "$skillsDest\save.js"
Invoke-WebRequest -Uri "$githubRaw/skills/hippocampus/clear.js" -OutFile "$skillsDest\clear.js"
Invoke-WebRequest -Uri "$githubRaw/skills/hippocampus/stats.js" -OutFile "$skillsDest\stats.js"

Write-Host "   ✓ Skills installed to: $skillsDest" -ForegroundColor Green
Write-Host ""

# Setup hook
Write-Host "[4/5] Setting up automatic hook..." -ForegroundColor Yellow

Invoke-WebRequest -Uri "$githubRaw/hooks/post-session-start.js" -OutFile "$hooksDir\post-session-start.js"

Write-Host "   ✓ Hook created: $hooksDir\post-session-start.js" -ForegroundColor Green
Write-Host ""

# Verify Python
Write-Host "[5/5] Verifying Python installation..." -ForegroundColor Yellow

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = & python --version 2>&1
    Write-Host "   ✓ Python found: $pythonVersion" -ForegroundColor Green
    Write-Host "   ✓ Python 3.7+ is required" -ForegroundColor Green
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $pythonVersion = & python3 --version 2>&1
    Write-Host "   ✓ Python 3 found: $pythonVersion" -ForegroundColor Green
    Write-Host "   ✓ Python 3.7+ is required" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Python not found. Please install Python 3.7+" -ForegroundColor Yellow
    Write-Host "   The plugin will not work without Python." -ForegroundColor Yellow
}
Write-Host ""

# Final summary
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              Installation Complete!                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Installed:" -ForegroundColor Cyan
Write-Host "  • Plugin: $pluginDest" -ForegroundColor Gray
Write-Host "  • Skills: $skillsDest" -ForegroundColor Gray
Write-Host "  • Hook:   $hooksDir\post-session-start.js" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️ Important Notes:" -ForegroundColor Yellow
Write-Host "  • This installation does NOT modify your existing Claude Code settings" -ForegroundColor Gray
Write-Host "  • Only adds CC-Hippocampus plugin, skills, and one hook file" -ForegroundColor Gray
Write-Host "  • Your existing plugins and settings remain unchanged" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Restart Claude Code to activate hooks" -ForegroundColor Gray
Write-Host "  2. Memory will auto-load on session start" -ForegroundColor Gray
Write-Host "  3. Use skills: /hippocampus-load, /hippocampus-save, etc." -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Done! No git clone required." -ForegroundColor Green
Write-Host ""
