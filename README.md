# x86/x64 Assembly Project Template

This is a template for creating **x86 and x64 assembly projects** using the MASM assembler. It is configured for use with Visual Studio Code and supports building, executing, and debugging your assembly code with ease.

## Features

- **Supports x86 and x64 Assembly**: Easily switch between 32-bit and 64-bit assembly projects.
- **Great for Bigger Projects**: Automatically assemble all `.asm` files in the `src` directory and all subdirectories.
- **Debugging**: Full debugging support using MSVC. Set breakpoints, step through code, and inspect registers.
- **Build Shortcut**: Quickly build your project using build shortcuts (default `Ctrl+Shift+B`).
- **Execute with F5**: Run your project directly from VS Code using the `F5` key.
- **Syntax Highlighting**: Enhanced syntax highlighting with the "ASM Code Lens" extension.

## Requirements

1. **Install Visual Studio 2022 and MASM**:

   - **Download and Install Visual Studio 2022**:
     - Go to the [Visual Studio 2022 download page](https://visualstudio.microsoft.com/vs/).
     - Download the installer and follow the installation instructions.

   - **Install MASM and MSVC Build Tools**:
     - During the Visual Studio installation, select the "Desktop development with C++" workload. This will install MASM and the necessary MSVC C++ x64/x86 build tools.

2. **Visual Studio Code**:

   - Download and install [Visual Studio Code](https://code.visualstudio.com/).

3. **Change VS Code Settings**:

   - Go to `File` > `Preferences` > `Settings`.
   - Search for `debug.AllowBreakpointsEverywhere` and set it to `true`. This allows you to place breakpoints in your assembly code.

4. **C/C++ Debug Extension**:

   - Download and install the [C/C++ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) for debugging support.

5. **ASM Code Lens Extension**:

   - For enhanced syntax highlighting, download and install the [ASM Code Lens](https://marketplace.visualstudio.com/items?itemName=maziac.asm-code-lens) extension from the VS Code Marketplace.

## Getting Started

1. **Install the Necessary Requirements**:

   Follow the steps in the "Requirements" section above to download and install all the necessary tools.

2. **Clone or Download the Template**:

   Click the green "Use this Template" button on the top right of this page. Alternatively, you can clone the repository or download the template as a ZIP file and extract it to your desired project location.

3. **Open in Visual Studio Code**:

   Open the project folder in Visual Studio Code.

4. **Configure Build Script (If Necessary)**:

   The build script `build.ps1` automatically locates the necessary paths for building your project. However, if your installation paths differ from the defaults, or if you want to switch between x86 and x64 assembly, you may need to adjust the variables at the top of `build.ps1`:

   - **User-Defined Paths in `build.ps1`**:

     ```powershell
     # User-defined paths (adjust these paths to match your system)
     $visualStudioDir = 'C:\Program Files\Microsoft Visual Studio\2022\Community'
     $windowsKitsDir = 'C:\Program Files (x86)\Windows Kits\10'
     ```

     These paths are set to the default installation directories. If you installed Visual Studio or Windows Kits in a different location, update these variables accordingly.

   - **Host Architecture**:

     By default, the build script is set to target a 64-bit host architecture:

     ```powershell
     $hostArch = 'x64'  # Change to 'x86' if your computer is 32-bit
     ```

     If your machine is 32-bit, change `$hostArch` to `'x86'`. Most modern PCs are 64-bit, so this change is usually unnecessary.

   - **Target Architecture (Switch Between x86 and x64 Assembly)**:

     To switch between building x86 (32-bit) and x64 (64-bit) assembly code, adjust the `$targetArch` variable:

     ```powershell
     $targetArch = 'x86'  # Change to 'x64' to build 64-bit assembly
     ```

     - Set `$targetArch` to `'x86'` to build 32-bit assembly code.
     - Set `$targetArch` to `'x64'` to build 64-bit assembly code.

     After changing this variable, the build script will assemble and link your code for the specified architecture.

5. **Update Your Assembly Code (If Necessary)**:

   - Ensure your assembly code is compatible with the target architecture.
   - For x64 assembly, you will need to adjust your code to use 64-bit registers and calling conventions.
   - Update the entry point label in your code if necessary (e.g., `MainEntryPoint` for x64).

6. **Build the Project**:

   Use the build shortcut (default `Ctrl+Shift+B`) to assemble and link your project. The build task will execute `build.ps1`. Alternatively, just press `F5` to run the project right away.

7. **Debug and Run the Project**:

   Press `F5` to start debugging. You can set breakpoints, step through code, and inspect registers.

## Configuration Files

- **launch.json**: Configuration for debugging with MSVC.
- **tasks.json**: Contains tasks for building the project, which invoke `build.ps1`.

## Example Code

Here's a basic sample of `main.asm` for **x86**:

```assembly
; x86 Assembly Example
; INCLUDES - Libraries required for the functionality of the program.
INCLUDELIB kernel32.lib                     ; Used for ExitProcess


; PROGRAM CONFIGURATION - Defines the processor, memory model, and stack size.
.386                                        ; Using x86_32 architecture
.model flat, stdcall
.stack 4096


; FUNCTION PROTOTYPES - Declaration of external functions used in this program.
ExitProcess PROTO dwExitCode:DWORD


; DATA SEGMENT - Reserved space for data used in the program.
.DATA


; CODE SEGMENT - Contains the actual code (instructions) of the program.
.CODE                   
    MainEntryPoint PROC                     ; Start of main procedure - Entry point of the program

        ; Your code here

        INVOKE ExitProcess, 0
    MainEntryPoint ENDP                     ; End of main procedure


; END OF FILE - Specifies the entry point and marks the end of this source file.
END MainEntryPoint                          ; End of program, specify the entry point

```

And here's an example for **x64**:

```assembly
; x64 Assembly Example
; INCLUDES - Libraries required for the functionality of the program.
INCLUDELIB kernel32.lib         ; Used for ExitProcess


; FUNCTION PROTOTYPES - Declaration of external functions used in this program.
ExitProcess PROTO


; DATA SEGMENT - Reserved space for data used in the program.
.DATA


; CODE SEGMENT - Contains the actual code (instructions) of the program.
.CODE
MainEntryPoint PROC             ; Start of main procedure - Entry point of the program

    ; Your code here

    sub rsp, 28h                ; Reserved the stack area as parameter passing area.
    CALL ExitProcess
MainEntryPoint ENDP             ; End of the main procedure.

END                             ; End of the Assembly program.
```

## Troubleshooting

- **Build Errors**:
  - If you encounter errors during the build process, ensure that Visual Studio and the Windows SDK are installed correctly.
  - Verify that the `$visualStudioDir` and `$windowsKitsDir` variables in `build.ps1` match your installation paths if they differ from the defaults.

- **Host and Target Architectures**:
  - Ensure that the `$hostArch` variable in `build.ps1` matches your system architecture (`'x64'` for 64-bit systems, `'x86'` for 32-bit systems).
  - Set the `$targetArch` variable to the architecture you want to build for (`'x86'` or `'x64'`).

- **Code Compatibility**:
  - Ensure your assembly code is written for the target architecture.
  - Adjust registers, calling conventions, and data sizes as necessary for x86 vs. x64.

- **Entry Point Label**:
  - For x86, if your entry point uses `stdcall`, the linker expects a decorated name (e.g., `MainEntryPoint@0`).
  - For x64, use the undecorated name (e.g., `MainEntryPoint`).

- **Breakpoints**:
  - Ensure `debug.AllowBreakpointsEverywhere` is set to `true` in your VS Code settings to place breakpoints in the editor.

- **Extensions**:
  - Make sure you have installed the required VS Code extensions: C/C++ extension and ASM Code Lens.

By following these steps and using this template, you can efficiently create and manage your x86 and x64 assembly projects in Visual Studio Code.

Happy coding!
