section .data
    radius dq 4 ; ([int] radius^2)
    maxIter dd 50

section .text
global mandelbrot

mandelbrot:
    push rbp
    mov rbp, rsp
    push r14
    push r15
    mov rax, rdi ; RAX will always be our address to the bitmap!
    mov r13, rcx ; r13 will be the scale (0 - ...)
    mov r14, rsi ; r14 will be the width of the window
    mov r15, rdx ; r15 will be the height of the window
    movsd xmm5, xmm0 ; xmm5 will be our scale
    movsd xmm8, xmm1 ; xmm8 will be move_right arg
    movsd xmm9, xmm2 ; xmm9 will be move_up arg

    call generate

    pop r15
    pop r14
    mov rsp, rbp
    pop rbp
    ret

drawPixel:
    ; RDI - x, RSI - y, EDX - colour
    ; we draw pixel at this location depending on the address
    ; of our bitmap that is always is in RAX registry
    ; return None
    push r8

    mov r10, rdi ;x
    mov r11, rsi ;y

    imul r11, r14
    add r11, r10
    imul r11, 4

    mov r8, rax
    add r8, r11
    mov [r8], edx

    pop r8
    ret

fromXYtoComplex:
    ; arguments: RDI - x and RSI - y
    ; map these values into <-2; 2>
    ; return xmm0, xmm1 (x, y)

    ; FOR NOW WE ASSUME THAT WIDHT AND HEIGHT IS DIVISBLE BY 4, LATER FIGURE STH OUT

    mov rcx, rdi ;x
    mov rdx, rsi ;y
    mov r10, r14
    shr r10, 1    ; r10 = width/2
    sub rcx, r10
    shr r10, 1   ; r10 = width/4 (it will be used to map values)

    mov r11, r15
    shr r11, 1   ; r11 = height/2
    sub rdx, r11
    shr r11, 1   ; r11 = height/4

    cvtsi2sd xmm0, rcx
    cvtsi2sd xmm1, rdx
    cvtsi2sd xmm2, r10
    cvtsi2sd xmm3, r11

    divsd xmm0, xmm2
    divsd xmm1, xmm3

    mulsd xmm0, xmm5
    addsd xmm0, xmm8
    mulsd xmm1, xmm5
    addsd xmm1, xmm9

    ret

generateColour:
    ; EDI - number of iterations
    ; calculates colour
    ; return EDX (colour)

    mov ecx, edi ; number of iterations
    cmp ecx, 0
    jl black ; if number of iteratoins is -1 then the colours is black

    ; shifts: 3, 5, 4 / 4, 8 ,4
    xor edx, edx
    mov r10d, 255
    sub r10d, ecx
    shl r10d, 3
    add edx, r10d
    shl r10d, 5
    add edx, r10d
    shl r10d, 4
    add edx, r10d
    jmp returnCol
black:
    xor edx, edx
returnCol:
    ret

mandelIterTestNumber:
    ; xmm0 - x, xmm1 - y
    ; calculate the number of iterations after which our complex number will leave the circle
    ; return EDI (number of iterations)
    xor edi, edi   ; iteration counter

    movsd xmm6, xmm0 ; original x
    movsd xmm7, xmm1 ; original y

loop:
    movsd xmm2, xmm0
    mulsd xmm2, xmm2 ; a^2
    movsd xmm3, xmm1
    mulsd xmm3, xmm3 ; b^2
    subsd xmm2, xmm3 ; a^2 - b^2
    movsd xmm4, xmm0
    mulsd xmm4, xmm1
    mov r10, 2
    cvtsi2sd xmm3, r10
    mulsd xmm4, xmm3 ; 2ab

    addsd xmm2, xmm6 ; a^2 - b^2 + Re(c)
    addsd xmm4, xmm7 ; 2ab + Im(c)
    movsd xmm0, xmm2
    movsd xmm1, xmm4

    ; check if |z^2 + c| >= radius^2
    movsd xmm2, xmm0
    mulsd xmm2, xmm2 ; new a^2
    movsd xmm3, xmm1
    mulsd xmm3, xmm3 ; new b^2
    addsd xmm2, xmm3 ; xmm2 = xmm2 + xmm3

    mov r10, [radius]
    cvtsi2sd xmm3, r10
    comisd xmm2, xmm3
    jae returnIter

    inc edi
    cmp edi, [maxIter]
    jl loop

    mov edi, -1     ; when we are here, it means that the number didn't leave the circle, so its color will be black in the future
    jmp returnIter
returnIter:
    ret

generate:
    push r8
    push r9

    xor r8, r8 ; x
loopX:
    xor r9, r9 ; y
loopY:
    mov rdi, r8
    mov rsi, r9
    call fromXYtoComplex ;after that we will have (x, y) in xmm0, xmm1
    call mandelIterTestNumber ; after that we will have num of iterations in EDI
    call generateColour ; after that we will have colour in EDX
    mov rdi, r8
    mov rsi, r9
    call drawPixel

    inc r9
    cmp r9, r15
    jl loopY

    inc r8
    cmp r8, r14
    jl loopX
end:
    pop r9
    pop r8
    ret
