; =============================================================================
; INCLUDES - Libraries required for the functionality of the program.
; =============================================================================
includelib kernel32.Lib                     ; Used for ExitProcess
includelib ucrt.lib                         ; Used for: printf, gets
includelib legacy_stdio_definitions.lib     ; Used for: printf, gets

; =============================================================================
; PROGRAM CONFIGURATION - Defines the processor, memory model, and stack size.
; =============================================================================
.386                                        ; Using x86_32 architecture
.model flat, stdcall
.stack 4096

; =============================================================================
; FUNCTION PROTOTYPES - Declaration of external functions used in this program.
; =============================================================================
ExitProcess PROTO, dwExitCode:DWORD ; Terminates the current process and returns an exit code to the operating system.
; Parameters:
;   dwExitCode : DWORD - The exit code for the process.
; Usage:
;   INVOKE ExitProcess, exitCodeVariable

printf PROTO C :VARARG ; Declares the "printf" function from the C Standard Library. Print's text to the console.
; Follows the C calling convention which requires the caller to clean up the stack. Accepts variable arguments.
; Usage:
;   Printing a simple string:
;     push offset string        ; Push the address of the string onto the stack
;     call printf               ; Call the printf function to print the string
;     add esp, 4                ; Correct the stack by popping the pushed address
;   Printing formatted text:
;     push value                ; Push each variable to format into the string
;     push offset formatString  ; Push the format string's address
;     call printf               ; Execute the printf function
;     add esp, 8                ; Restore the stack by removing parameters

gets PROTO C, :VARARG ; Declares the "gets" function from the C Standard Library. Retrieves input from the user.
; Follows the C calling convention which requires the caller to clean up the stack. 
; NOTE: This is considered unsafe because it does not check for buffer overflows. Use alternatives like "fgets", "scanf", "ReadConsole", etc in real applications.
; Usage:
;   Get the user's input:
;     push offset inputString   ; Push the address where the response will be stored onto the stack.
;     call gets                 ; Call the gets function to get the user's input
;     add esp, 4                ; Correct the stack by popping the pushed address


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
    MainEntryPoint PROC                                     ; Start of main procedure - Entry point of the program

        ; Your code here
        ; Below is an example of asking the user for input and printing it back to them.

        ; Ask the user to enter some text.
        push offset strPrompt                               ; Push the address of the question onto the stack.
        call printf                                         ; Print question to console.
        add esp, 4                                          ; Clean up the "strPrompt" argument from the stack (for cdecl).

        ; Get the user's response.
        push offset strUserInput                            ; Push the address of the input buffer string.
        call gets                                           ; Get the user's input, storing it in the input string.
        add esp, 4                                          ; Clean up the "strUserInput" argument from the stack (for cdecl).

        ; Print back what the user typed in a formatted message.
        push offset strUserInput                            ; Push the address of the user's input onto the stack.
        push offset strOutputFormat                         ; Push formatted output string onto the stack.
        call printf                                         ; Print response back to user.
        add esp, 8                                          ; Clean up the "strUserInput" and "strOutputFormat" arguments from the stack (for cdecl).
		
        INVOKE ExitProcess, 0                               ; Exit program
    MainEntryPoint ENDP                                     ; End of main procedure


; =============================================================================
; END OF FILE - Specifies the entry point and marks the end of this source file.
; =============================================================================
END MainEntryPoint                                          ; End of program, specify the entry point