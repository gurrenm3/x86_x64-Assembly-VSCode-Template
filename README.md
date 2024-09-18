# x86 Assembly Project Template

This is a template for creating x86 assembly projects using the MASM assembler. It is configured for use with Visual Studio Code and supports building, executing, and debugging your assembly code with ease.

## Features

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
   - **Install MASM**:
     - During the Visual Studio installation, select the "Desktop development with C++" workload.
     - Ensure the "MSVC v142 - VS 2019 C++ x64/x86 build tools" component is selected.
   - **Set Up Environment Variables**:
     - After installation, add the MASM directory to your environment variables. Typically, the directory is located somewhere like:
       ```
       C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx86\x86
       ```
     - In the path above, "2022" is the year of Visual Studio and "14.29.30133" would be the current version of the IDE. They may be slightly different for you as it depends on your current install.
     - IMPORTANT: You should add both the x86 "Hostx86\x86" and x64 "Hostx64\x64" folders to your Environment variables to prevent issues.

2. **Visual Studio Code**:
   - Download and install [Visual Studio Code](https://code.visualstudio.com/). This is what you will be writing your actual code in.

3. **Change VS Code Settings**:
    Go to `File` > `Preferences` > `Settings`.
    Search for `debug.AllowBreakpointsEverywhere` and set it to `true`. This allows you to place breakpoints in your assembly code.

4. **ASM Code Lens Extension**:
   - For unparalleled syntax highlighting, download and install the [ASM Code Lens](https://marketplace.visualstudio.com/items?itemName=maziac.asm-code-lens) extension from the VS Code Marketplace.

## Getting Started

1. **Install the Necessary Requirements**:
    Follow the steps in the "Requirements" section above to download and install all the necessary tools.

2. **Clone or Download the Template**:
    Click the green "Use this Template" button on the top right of this page. Alternatively, you can clone the repository or download the template as a ZIP file and extract it to your desired project location.

3. **Open in Visual Studio Code**:
    Open the project folder in Visual Studio Code.

4. **Configure Build Paths**:
    Open the `.vscode\build.ps1` file. Change the include and library paths in the `$includePaths` and `$libPaths` arrays to match the ones on your system. This will let your code build with the correct dependencies.
    
    - In the `$includePaths` array:
    ```
    $includePaths = @(
        'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.41.34120\include',  # Change this to match your system.
        'C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\um'                              # Change this to match your system.
    )
    ```
    - In the `$libPaths` array:
    ```
    $libPaths = @(
        'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.41.34120\lib\x86',  # Change this to match your system.
        'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x86',                           # Change this to match your system.
        'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x86'                              # Change this to match your system.
    )

    ```
    - NOTE: If you have problems building, make sure these paths are correct and point to the appropriate include and library directories on your system.

5. **Build the Project**:
    Use the build shortcut (default `Ctrl+Shift+B`) to assemble and link your project. The build task will execute build.ps1. Alternatively, just press F5 to run the project right away.

6. **Debug and Run the Project**:
    Press F5 to start debugging. You can set breakpoints, step through code, and inspect registers.


## Configuration Files

- **launch.json**: Configuration for debugging with MSVC.
- **tasks.json**: Contains tasks for building the project, which invoke `build.ps1`.

## Example Code

Here’s a sample of what your `main.asm` will look like:

```assembly
; =============================================================================
; DATA SEGMENT - Reserved space for data used in the program.
; =============================================================================
.data
	; Define any necessary data here, e.g., strings or constants.
	strPrompt db "Please enter some text: ", 0          ; String prompt to ask the user to enter some text.
	strUserInput db 256 dup(0)                          ; Buffer to store the input string
	strOutputFormat db "You entered: %s", 0Ah, 0        ; Formatted output message to print result back to the user.

; =============================================================================
; CODE SEGMENT - Contains the actual code (instructions) of the program.
; =============================================================================
.code                   
    MainEntryPoint PROC                                 ; Start of main procedure - Entry point of the program

        ; Your code here
        ; Below is an example of asking the user for input and printing it back to them.

        ; Ask the user to enter some text.
        push offset strPrompt                           ; Push the address of the question onto the stack.
        call printf                                     ; Print question to console.
        add esp, 4                                      ; Clean up the "strPrompt" argument from the stack (for cdecl).

        ; Get the user's response.
        push offset strUserInput                        ; Push the address of the input buffer string.
        call gets                                       ; Get the user's input, storing it in the input string.
        add esp, 4                                      ; Clean up the "strUserInput" argument from the stack (for cdecl).

        ; Print back what the user typed in a formatted message.
        push offset strUserInput                        ; Push the address of the user's input onto the stack.
        push offset strOutputFormat                     ; Push formatted output string onto the stack.
        call printf                                     ; Print response back to user.
        add esp, 8                                      ; Clean up the "strUserInput" and "strOutputFormat" arguments from the stack (for cdecl).

        INVOKE ExitProcess, 0                           ; Exit program
    MainEntryPoint ENDP                                 ; End of main procedure

END MainEntryPoint                                      ; End of program, specify the entry point
```

Troubleshooting

   - Environment Variables: Ensure that the MASM directory is correctly added to your environment variables.
   - Dependencies: Make sure all dependencies are correctly installed and their paths are correctly set in `build.ps1`.
   - Breakpoints: Ensure `debug.AllowBreakpointsEverywhere` is set to `true` in your VS Code settings to place breakpoints in the editor.

By following these steps and using this template, you can efficiently create and manage your x86 assembly projects in Visual Studio Code.

Happy coding!