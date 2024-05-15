# x86 Assembly Project Template

This is a template for creating x86 assembly projects using the MASM assembler. It is configured for use with Visual Studio Code and supports building, executing, and debugging your assembly code with ease.

## Features

- **Build Shortcut**: Quickly build your project using the build shortcut.
- **Debugging**: Full debugging support using MSVC. Set breakpoints, step through code, and inspect registers.
- **Execute with F5**: Run your project directly from VS Code using the F5 key.
- **Syntax Highlighting**: Enhanced syntax highlighting with the "ASM Code Lens" extension.

## Requirements

- **MASM Assembler**: MASM is installed with the Visual Studio IDE. Ensure that the MASM directory is added to your environment variables. Typically, the directory is located at: "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\ **{YOUR VS VERSION HERE}}** \bin\Hostx86\x86"

- **Visual Studio Code**: Download and install [Visual Studio Code](https://code.visualstudio.com/).
- **ASM Code Lens Extension**: For unparalleled syntax highlighting, download and install the [ASM Code Lens](https://marketplace.visualstudio.com/items?itemName=maziac.asm-code-lens) extension from the VS Code Marketplace.
- **NOTE:** Users should add both x86 and x64 bit versions of any dependencies.


## Getting Started

1. **Clone or Download the Template**:
    Clone the repository or download the template as a ZIP file and extract it to your desired project location.

2. **Open in Visual Studio Code**:
    Open the project folder in Visual Studio Code.

3. **Set Up Environment Variables**:
    Add the MASM directory to your environment variables. This allows VS Code to access the MASM tools.

4. **Change VS Code Settings**:
    Go to `File` > `Preferences` > `Settings`.
    Search for `debug.AllowBreakpointsEverywhere` and set it to `true`. This allows you to place breakpoints in your assembly code.

5. **Build the Project**:
    Use the build shortcut (default `Ctrl+Shift+B`) to assemble and link your project.

6. **Debug and Run the Project**:
    Press F5 to start debugging. You can set breakpoints, step through code, and inspect registers.

## Project Structure

AssemblyProjectTemplate/
├── .vscode/
│ ├── launch.json # Debug configuration
│ └── tasks.json # Build tasks configuration
├── build/ # Build output directory
├── src/
│ └── main.asm # Sample assembly source file
└── README.md # Project documentation


## Configuration Files

- **launch.json**: Configuration for debugging with MSVC.
- **tasks.json**: Tasks for assembling and linking the project using MASM.

## Example Code

Here’s a sample of what your `main.asm` might look like:

```assembly
; Program Configuration
.386
.model flat, stdcall
.stack 4096

; Data segment
.data

; Code segment
.code                   
main PROC
    nop ; Code start
    push ecx

    nop ; Code end
    ret
main ENDP
END main
```

Troubleshooting

   - Environment Variables: Ensure that the MASM directory is correctly added to your environment variables.
   - Dependencies: Make sure all dependencies are correctly installed and their paths are correctly set.
   - Breakpoints: Ensure debug.AllowBreakpointsEverywhere is set to true in your VS Code settings to place breakpoints in the editor.

By following these steps and using this template, you can efficiently create and manage your x86 assembly projects in Visual Studio Code.

Happy coding!