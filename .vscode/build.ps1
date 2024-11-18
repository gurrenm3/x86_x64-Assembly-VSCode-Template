# ================================================================
# Build Script for x86/x64 Assembly Projects
# ================================================================

# User-defined paths (adjust these paths to match your system)
$visualStudioDir = 'C:\Program Files\Microsoft Visual Studio\2022\Community'
$windowsKitsDir = 'C:\Program Files (x86)\Windows Kits\10'

# ================================
# Host Architecture Configuration
# ================================

# Define the host architecture: 'x86' or 'x64'
# Set this variable based on your target environment
$hostArch = 'x64'  # Change to 'x86' if targeting a 32-bit environment

# Validate the host architecture
if ($hostArch -ne 'x86' -and $hostArch -ne 'x64') {
    Write-Host "Error: Invalid host architecture specified. Please set `\$hostArch` to either 'x86' or 'x64'." -ForegroundColor Red
    exit 1
}

# Construct the Host directory based on the host architecture
$hostDir = "Host$hostArch"

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

# Set lib paths
$libPaths = @(
    (Join-Path $latestMsvcVersionDir 'lib\x86'),
    (Join-Path $windowsKitsDir "Lib\$latestWindowsSdkVersion\um\x86"),
    (Join-Path $windowsKitsDir "Lib\$latestWindowsSdkVersion\ucrt\x86")
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

# Define the Host directory based on host architecture
$mlExePathCandidates = @(
    (Join-Path $latestMsvcVersionDir "bin\$hostDir\x86\ml.exe"),
    (Join-Path $latestMsvcVersionDir "bin\$hostDir\x86\ml.exe")
)

$mlExePath = $mlExePathCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (!$mlExePath) {
    Exit-WithError "Error: ml.exe not found in expected locations."
}
Write-Host "Found ml.exe at: $mlExePath"

$linkExePathCandidates = @(
    (Join-Path $latestMsvcVersionDir "bin\$hostDir\x86\link.exe"),
    (Join-Path $latestMsvcVersionDir "bin\$hostDir\x86\link.exe")
)

$linkExePath = $linkExePathCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (!$linkExePath) {
    Exit-WithError "Error: link.exe not found in expected locations."
}
Write-Host "Found link.exe at: $linkExePath"

# =========================================
# Initialize Visual Studio Environment
# =========================================

$vcVarsAllBat = Join-Path $visualStudioDir 'VC\Auxiliary\Build\vcvarsall.bat'
if (!(Test-Path $vcVarsAllBat)) {
    Exit-WithError "Error: vcvarsall.bat not found at $vcVarsAllBat"
}
Write-Host "Initializing Visual Studio environment for host architecture '$hostArch'..."
& "$vcVarsAllBat" $hostArch
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
    
    # Removed the script's own "Assembling" message to prevent duplication
    # Write-Host "Assembling $asmFile..."
    
    # Assemble the .asm file using ml.exe
    $includeArgs = $includePaths | ForEach-Object { "/I`"$($_)`"" }
    $mlArgs = @(
        '/c',
        '/Zd',
        '/coff'
    ) + $includeArgs + @(
        '/Fo', "`"$objFile`"",
        "`"$asmFile`""
    )
    
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
$linkArgs = @(
    '/DEBUG',
    '/SUBSYSTEM:CONSOLE',
    '/ENTRY:MainEntryPoint@0',
    '/OUT:build\main.exe'
) + $objFiles + $libArgs + @(
    '/SAFESEH:NO'
)
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
