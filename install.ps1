$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $ProjectDir ".venv"
$Python = "python"

Write-Host "================================"
Write-Host "        NEXUS INSTALLER"
Write-Host "================================"
Write-Host ""

# Check Python
Write-Host "[1/5] Checking Python..."

try {
    & $Python --version
}
catch {
    Write-Host ""
    Write-Host "ERROR: Python 3 is not installed or not available in PATH."
    Write-Host "Install Python from https://www.python.org/downloads/windows/"
    exit 1
}

# Create virtual environment
Write-Host "[2/5] Setting up virtual environment..."

if (-not (Test-Path $VenvDir)) {
    & $Python -m venv $VenvDir
}
else {
    Write-Host "Virtual environment already exists."
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$VenvPip = Join-Path $VenvDir "Scripts\pip.exe"

# Install dependencies
Write-Host "[3/5] Installing dependencies..."

& $VenvPip install --upgrade pip
& $VenvPip install -r (Join-Path $ProjectDir "requirements.txt")

# Create launcher
Write-Host "[4/5] Creating NEXUS launcher..."

$Launcher = Join-Path $ProjectDir "NEXUS.cmd"

@"
@echo off
cd /d "$ProjectDir"
"$VenvPython" "$ProjectDir\main.py"
"@ | Set-Content -Path $Launcher -Encoding ASCII

# Create Desktop shortcut
Write-Host "[5/5] Creating Desktop shortcut..."

$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "NEXUS.lnk"

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)

$Shortcut.TargetPath = $VenvPython
$Shortcut.Arguments = "`"$ProjectDir\main.py`""
$Shortcut.WorkingDirectory = $ProjectDir
$Shortcut.Description = "NEXUS - Personal AI Assistant"

$IconPath = Join-Path $ProjectDir "config\nexus.ico"

if (Test-Path $IconPath) {
    $Shortcut.IconLocation = $IconPath
}
else {
    Write-Host "WARNING: config\nexus.ico not found. Using default icon."
}

$Shortcut.Save()

Write-Host ""
Write-Host "================================"
Write-Host "       NEXUS INSTALLED"
Write-Host "================================"
Write-Host ""
Write-Host "Project : $ProjectDir"
Write-Host "Python  : $VenvPython"
Write-Host "Desktop : $ShortcutPath"
Write-Host ""
Write-Host "You can now launch NEXUS from the Desktop shortcut."
Write-Host ""
