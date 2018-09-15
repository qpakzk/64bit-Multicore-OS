[ORG 0x00]
[BITS 16]

SECTION .text

START:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    cli
    lgdt [ GDTR ]

    ; PG=0, CD=1, NW=0, AM=0, WP=0, NE=1, ET=1, TS=1, EM=0, MP=1, PE=1
    mov eax, 0x4000003B
    mov cr0, eax

    jmp dword 0x08: ( PROTECTEDMOED - $$ + 0x10000 )

[BITS 32]
PROTECTEDMOED:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    push ( SWITCHSUCCESSMESSAGE - $$ + 0x10000 )
    push 2
    push 0
    call PRINTMESSAGE
    add esp, 12

    jmp $

PRINTMESSAGE:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    mov eax, dword [ ebp + 12 ]
    mov esi, 80 * 2
    mul esi
    mov edi, eax

    mov eax, dword [ ebp + 8 ]
    mov esi, 2
    mul esi
    add edi, eax

    mov esi, dword [ ebp + 16 ]

.MESSAGELOOP:
    mov cl, [ esi ]
    
    cmp cl, 0
    je .MESSAGEEND

    mov byte [ edi + 0xB8000 ], cl

    add esi, 1
    add edi, 2

    jmp .MESSAGELOOP

.MESSAGEEND:
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret

align 8, db 0

dw 0x0000
GDTR:
    dw GDTEND - GDT - 1
    dd ( GDT - $$ + 0x10000 )

GDT:
    NULLDESCRIPTOR:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00

    CODEDESCRIPTOR:
        dw 0xFFFF ; Limit [15:0]
        dw 0x0000 ; Base [15:0]
        db 0x00 ; Base [19:16]
        db 0x9A ; P=1, DPL=00, S=1, Type=1010 (Code Segment, Execute/Read)
        db 0xCF ; G=1, D/B=1, L=0, AVL=0, Limit [19:16]
        db 0x00 ; Base [31:24]

    DATADESCRIPTOR:
        dw 0xFFFF ; Limit [15:0]
        dw 0x0000 ; Base [15:0]
        dw 0x00 ; Base [19:16]
        db 0x92 ; P=1, DPL=00, S=0, Type=0010 (Data Segment, Read/Write)
        db 0xCF ; G=1, D/B=1, L=0, AVL=0, Limit [19:16]
        db 0x00 ; Base [31:24]
GDTEND:

SWITCHSUCCESSMESSAGE: db 'Switch To Protected Mode Success~!!', 0

times 512 - ( $ - $$ ) db 0x00