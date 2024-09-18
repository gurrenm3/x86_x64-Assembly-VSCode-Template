# Set paths (adjust these paths to match your system)
$includePaths = @(
    'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.41.34120\include',
    'C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\um'
)
$libPaths = @(
    'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.41.34120\lib\x86',
    'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x86',
    'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x86'
)

# Optionally, set up the Visual Studio environment
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat' x86

# Create build directory if it doesn't exist
if (!(Test-Path -Path 'build')) {
    New-Item -ItemType Directory -Path 'build' | Out-Null
}

# Assemble all .asm files in src directory and subdirectories
Get-ChildItem -Path 'src' -Filter '*.asm' -Recurse | ForEach-Object {
    $asmFile = $_.FullName
    # Generate corresponding object file path in build directory
    $relativePath = $_.FullName.Substring((Get-Item 'src').FullName.Length + 1)
    $objFile = "build\$($relativePath -replace '\.asm$','.obj')"
    # Ensure the directory exists
    $objDir = Split-Path -Path $objFile -Parent
    if (!(Test-Path -Path $objDir)) {
        New-Item -ItemType Directory -Path $objDir -Force | Out-Null
    }
    Write-Host "Assembling $asmFile..."
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
    $processInfo.FileName = 'ml.exe'
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

# Link all object files
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
$processInfo.FileName = 'link.exe'
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
