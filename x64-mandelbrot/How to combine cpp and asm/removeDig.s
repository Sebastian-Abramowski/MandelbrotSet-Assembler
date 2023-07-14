;eax - adres odczytu
;ebx - pomocznicy adres
;cl - pojedyncza litera

section .text
global removeDig
removeDig:
    push ebp
    mov ebp, esp
    push ebx
    mov eax, [ebp+8]
loop:
    mov cl, [eax]   ;load
    test cl, cl
    jz end

    cmp cl, '0'
    jl next
    cmp cl, '9'
    jg next

    jmp remove
next:
    inc eax
    jmp loop

remove:
    push eax
    mov ebx, eax
    inc ebx
remove_loop:
    mov cl, [ebx]
    mov [eax], cl

    test cl, cl
    jz after_removal
    inc eax
    inc ebx
    jmp remove_loop
after_removal:
    pop eax
    jmp loop

end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret
