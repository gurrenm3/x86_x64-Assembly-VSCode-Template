# ================================================================
# Build Script for x86/x64 Assembly Projects
# ================================================================

# User-defined paths (adjust these paths to match your system)
$visualStudioDir = 'C:\Program Files\Microsoft Visual Studio\2022\Community'
$windowsKitsDir = 'C:\Program Files (x86)\Windows Kits\10'

# ================================
# Host and Target Architecture Configuration
# ================================

# Define the host architecture: 'x86' or 'x64'
# Set this variable based on your development environment
$hostArch = 'x64'  # Change to 'x86' if your machine is 32-bit

# Define the target architecture: 'x86' or 'x64'
# Set this variable based on the architecture you want to build for
$targetArch = 'x86'  # Change to 'x64' to build 64-bit applications

# Validate the host architecture
if ($hostArch -ne 'x86' -and $hostArch -ne 'x64') {
    Write-Host "Error: Invalid host architecture specified. Please set `\$hostArch` to either 'x86' or 'x64'." -ForegroundColor Red
    exit 1
}

# Validate the target architecture
if ($targetArch -ne 'x86' -and $targetArch -ne 'x64') {
    Write-Host "Error: Invalid target architecture specified. Please set `\$targetArch` to either 'x86' or 'x64'." -ForegroundColor Red
    exit 1
}

# Construct the Host directory based on the host architecture
$hostDir = "Host$hostArch"

# Map architectures for Visual Studio environment variables
$vsHostArch = if ($hostArch -eq 'x64') { 'amd64' } else { 'x86' }
$vsTargetArch = if ($targetArch -eq 'x64') { 'amd64' } else { 'x86' }

# Function to print error and exit
function Exit-WithError {
    param (
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Red
    exit 1
}

# ==================================
# Locate MSVC and Windows SDK Paths
# ==================================

# Find the latest MSVC version
$msvcToolsDir = Join-Path $visualStudioDir 'VC\Tools\MSVC'
if (!(Test-Path $msvcToolsDir)) {
    Exit-WithError "Error: MSVC Tools directory not found at $msvcToolsDir"
}

$msvcVersionDirs = Get-ChildItem -Path $msvcToolsDir -Directory | Sort-Object Name -Descending
if ($msvcVersionDirs.Count -eq 0) {
    Exit-WithError "Error: No MSVC versions found in $msvcToolsDir"
}
$latestMsvcVersionDir = $msvcVersionDirs[0].FullName
Write-Host "Latest MSVC version found: $latestMsvcVersionDir"

# Find the latest Windows SDK version
$windowsSdkIncludeDir = Join-Path $windowsKitsDir 'Include'
if (!(Test-Path $windowsSdkIncludeDir)) {
    Exit-WithError "Error: Windows SDK Include directory not found at $windowsSdkIncludeDir"
}

$windowsSdkVersionDirs = Get-ChildItem -Path $windowsSdkIncludeDir -Directory | Sort-Object Name -Descending
if ($windowsSdkVersionDirs.Count -eq 0) {
    Exit-WithError "Error: No Windows SDK versions found in $windowsSdkIncludeDir"
}
$latestWindowsSdkVersion = $windowsSdkVersionDirs[0].Name
Write-Host "Latest Windows SDK version found: $latestWindowsSdkVersion"

# ========================
# Set Include and Lib Paths
# ========================

# Set include paths
$includePaths = @(
    (Join-Path $latestMsvcVersionDir 'include'),
    (Join-Path $windowsKitsDir "Include\$latestWindowsSdkVersion\um"),
    (Join-Path $windowsKitsDir "Include\$latestWindowsSdkVersion\ucrt"),
    (Join-Path $windowsKitsDir "Include\$latestWindowsSdkVersion\shared"),
    (Join-Path $windowsKitsDir "Include\$latestWindowsSdkVersion\winrt"),
    (Join-Path $windowsKitsDir "Include\$latestWindowsSdkVersion\cppwinrt")
)

# Set lib paths based on target architecture
$libPaths = @(
    (Join-Path $latestMsvcVersionDir "lib\$targetArch"),
    (Join-Path $windowsKitsDir "Lib\$latestWindowsSdkVersion\um\$targetArch"),
    (Join-Path $windowsKitsDir "Lib\$latestWindowsSdkVersion\ucrt\$targetArch")
)

# ============================
# Debugging: Print Paths
# ============================

Write-Host "Include Paths:"
$includePaths | ForEach-Object { Write-Host "  $_" }

Write-Host "Library Paths:"
$libPaths | ForEach-Object { Write-Host "  $_" }

# ======================================
# Verify Include and Library Paths Exist
# ======================================

foreach ($path in $includePaths + $libPaths) {
    if (!(Test-Path $path)) {
        Exit-WithError "Error: Path does not exist - $path"
    }
}

# ======================
# Locate ml.exe and link.exe
# ======================

# Determine the assembler executable based on target architecture
$mlExeName = if ($targetArch -eq 'x86') { 'ml.exe' } else { 'ml64.exe' }
$mlExePath = Join-Path $latestMsvcVersionDir "bin\$hostDir\$targetArch\$mlExeName"

if (!(Test-Path $mlExePath)) {
    Exit-WithError "Error: $mlExeName not found at $mlExePath"
}
Write-Host "Found $mlExeName at: $mlExePath"

$linkExePath = Join-Path $latestMsvcVersionDir "bin\$hostDir\$targetArch\link.exe"
if (!(Test-Path $linkExePath)) {
    Exit-WithError "Error: link.exe not found at $linkExePath"
}
Write-Host "Found link.exe at: $linkExePath"

# =========================================
# Initialize Visual Studio Environment
# =========================================

$vcVarsAllBat = Join-Path $visualStudioDir 'VC\Auxiliary\Build\vcvarsall.bat'
if (!(Test-Path $vcVarsAllBat)) {
    Exit-WithError "Error: vcvarsall.bat not found at $vcVarsAllBat"
}
Write-Host "Initializing Visual Studio environment for host architecture '$vsHostArch' and target architecture '$vsTargetArch'..."
& "$vcVarsAllBat" $vsHostArch $vsTargetArch
Write-Host "Environment initialized."

# =====================
# Create Build Directory
# =====================

if (!(Test-Path -Path 'build')) {
    New-Item -ItemType Directory -Path 'build' | Out-Null
    Write-Host "Created build directory."
}

# ===============================
# Assemble All .asm Files in src
# ===============================

Get-ChildItem -Path 'src' -Filter '*.asm' -Recurse | ForEach-Object {
    $asmFile = $_.FullName
    # Generate corresponding object file path in build directory
    $relativePath = $_.FullName.Substring((Get-Item 'src').FullName.Length + 1)
    $objFile = Join-Path 'build' ($relativePath -replace '\.asm$','.obj')
    # Ensure the directory exists
    $objDir = Split-Path -Path $objFile -Parent
    if (!(Test-Path -Path $objDir)) {
        New-Item -ItemType Directory -Path $objDir -Force | Out-Null
    }
    
    # Assemble the .asm file using ml.exe or ml64.exe
    $includeArgs = $includePaths | ForEach-Object { "/I`"$($_)`"" }
    
    if ($targetArch -eq 'x86') {
        $mlArgs = @(
            '/c',
            '/Zd',
            '/coff'
        ) + $includeArgs + @(
            '/Fo', "`"$objFile`"",
            "`"$asmFile`""
        )
    } else {
        $mlArgs = @(
            '/c',
            '/Zi'
        ) + $includeArgs + @(
            '/Fo', "`"$objFile`"",
            "`"$asmFile`""
        )
    }
    
    # Start the process and capture output
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $mlExePath
    $processInfo.Arguments = [string]::Join(' ', $mlArgs)
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        Write-Host "Error assembling $asmFile" -ForegroundColor Red
        # Display error messages from stdout or stderr
        if ($stderr) {
            Write-Host $stderr -ForegroundColor Red
        }
        if ($stdout) {
            Write-Host $stdout -ForegroundColor Red
        }
        exit 1
    } else {
        Write-Host $stdout
    }
}

# ===================
# Link All Object Files
# ===================

Write-Host "Linking object files..."
# Collect all .obj files from build directory and subdirectories
$objFiles = Get-ChildItem -Path 'build' -Filter '*.obj' -Recurse | ForEach-Object { "`"$($_.FullName)`"" }
$libArgs = $libPaths | ForEach-Object { "/LIBPATH:`"$($_)`"" }

# Set the entry point based on target architecture
$entryPoint = if ($targetArch -eq 'x86') { 'MainEntryPoint@0' } else { 'MainEntryPoint' }

if ($targetArch -eq 'x86') {
    $linkArgs = @(
        '/DEBUG',
        '/SUBSYSTEM:CONSOLE',
        "/ENTRY:$entryPoint",
        '/OUT:build\main.exe'
    ) + $objFiles + $libArgs + @(
        '/SAFESEH:NO'
    )
} else {
    $linkArgs = @(
        '/DEBUG',
        '/SUBSYSTEM:CONSOLE',
        "/ENTRY:$entryPoint",
        '/OUT:build\main.exe'
    ) + $objFiles + $libArgs
}

# Start the linker process and capture output
$processInfo = New-Object System.Diagnostics.ProcessStartInfo
$processInfo.FileName = $linkExePath
$processInfo.Arguments = [string]::Join(' ', $linkArgs)
$processInfo.RedirectStandardOutput = $true
$processInfo.RedirectStandardError = $true
$processInfo.UseShellExecute = $false
$processInfo.CreateNoWindow = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processInfo
$process.Start() | Out-Null
$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()
if ($process.ExitCode -ne 0) {
    Write-Host "Error linking object files" -ForegroundColor Red
    if ($stderr) {
        Write-Host $stderr -ForegroundColor Red
    }
    if ($stdout) {
        Write-Host $stdout -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host $stdout
}

Write-Host "Build successful!"
