format PE console
 
include 'win32a.inc'
 
entry start
 
section '.data' data readable writable
 
        ;strings to be printed later
        numberPrompt                    db 'Input the number (in range [0, 2^24))', 10, 0
        strReadInt                      db '%d', 0
        strPrintInt                     db '%d', 10, 0
        strInvalidWarning               db 'Invalid input', 10, 0
        printOnes                       db 'Amount of bits set to 1:', 10, 0
        printZeros                      db 'Amount of bits set to 0:', 10, 0
        exitPrompt                      db 'Press any key to exit', 10, 0

        ;variables for future use
        number                          dd 0
        ones                            dd 0
        zeros                           dd 24
 
 
section '.code' code readable executable
;========================= BEGIN main part BEGIN =========================
        start:
                ;ask to input numbery size
                push    numberPrompt
                call    [printf]
                
                ;read number
                push    number
                push    strReadInt
                call    [scanf]

                mov     eax,    [number]

                ;check invalid input
                cmp     eax,    0x1000000
                jge     invalidNum

        check_bit:
                cmp     eax,     0              ;if number is 0 than end program
                je      printFinalInfo
                mov     edx,    eax             ;copy number to edx
                and     edx,    0x1             ;check last bit of edx by using AND with 0x1
                cmp     edx,    1               ;compare result of AND with 1
                je      incOnes                 ;if it is 1 than increment amount of 1 bits (if it is 0 than do nothing)
                shr     eax,    1               ;shift bits 1 position to the right
                jmp     check_bit               ;continue the loop

        incOnes:
                ; increase count of ones
                mov     edx,    [ones]
                inc     edx
                mov     [ones], edx
                ; decrease number of zeros
                mov     edx,    [zeros]
                dec     edx
                mov     [zeros], edx

                shr     eax,    1               ;shift bits 1 position to the right
                jmp     check_bit               ;continue the loop

        invalidNum:
                ;print that user number is too big and end the program
                push    strInvalidWarning
                call    [printf]
                jmp     endProgram

        printFinalInfo:
                push    printOnes
                call    [printf]

                ;print amount of bits set to 1
                push    [ones]
                push    strPrintInt
                call    [printf]

                push    printZeros
                call    [printf]

                ;print amount of bits set to 0
                push    [zeros]
                push    strPrintInt
                call    [printf]

        endProgram:
                ;ask user to press any key to exit
                push    exitPrompt
                call    [printf]
                ;wait for user to press something before close console windows
                call    [getch] 
                push    0
                call    ExitProcess
;========================= END main part END =========================
 
section '.idata' data readable import
 
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
 
        import kernel,\
               ExitProcess, 'ExitProcess'
 
        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'