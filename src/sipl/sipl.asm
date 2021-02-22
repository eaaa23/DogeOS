[BITS 16]


org 0x8200

    MOV AL,0x0d
    CALL func_printchar
    MOV AL,0x0a
    CALL func_printchar


    MOV AX,0x1000
    MOV FS,AX
    MOV GS,AX

CHECKDISK_MAX EQU 0xff
CHECKDISK_SHOW_START EQU 0x80
CHECKDISK_SHOW_END EQU 0x80+24
    MOV DL,0
scanloop:
    ;scan disks
    MOV BH,0
    MOV BL,DL
    SHL BX,4   ; BX = DL * 16
    CALL func_checkdisk
    CMP DL,CHECKDISK_MAX
    JE end_scanloop
    INC DL
    JMP scanloop

end_scanloop:
    MOV CX,CHECKDISK_SHOW_START
    MOV BX,CX
    SHL BX,4

printloop:
    MOV DI,0
    MOV AL,'A'
    CALL func_printchar
    MOV DX,BX
    CALL func_printhex
    MOV AL,'D'
    CALL func_printchar
    MOV DH,0
    MOV DL,[FS:BX]
    CALL func_printhex
    MOV AL,'S'
    CALL func_printchar
    MOV DL,[FS:BX+1]
    CALL func_printhex
    MOV AL,'H'
    CALL func_printchar
    MOV DL,[FS:BX+2]
    CALL func_printhex
    MOV AL,'C'
    CALL func_printchar
    MOV DX,[FS:BX+3]
    CALL func_printhex
    MOV AL,'T'
    CALL func_printchar
    MOV EDX,[FS:BX+5]
    ROR EDX,16
    CALL func_printhex
    ROR EDX,16
    MOV DI,1
    CALL func_printhex
    ADD BX,16
    INC CX
    CMP CX,CHECKDISK_SHOW_END
    JNE printloop





    ; set up video mode:
    VBEMODE	EQU		0x115			; 1024x768x32
    ; VBE mode
    ;   0x100  :  640 x  400 x 8bit
    ;   0x101  :  640 x  480 x 8bit
    ;   0x105  : 1024 x  768 x 8bit
    ;   0x107  : 1280 x 1024 x 8bit
    ;   0x0112 : 640 x 480 x 32bit
    ;   0x0115 : 800 x 600 x 32bit
    ;   0x0118 : 1024 x 768 x 32bit
    VIDEO_INFO EQU 0xf000 ; FS:0xf000 = 0x1f000
    VMODE EQU 0xf000
    SCRNX EQU 0xf002
    SCRNY EQU 0xf004
    VRAM  EQU 0xf006

    MOV AX,0x9000
    MOV ES,AX
    MOV DI,0
    MOV AX,0x4f00
    INT 0x10
    CMP AX,0x004f
    JNE scrn320

    MOV AX,[ES:DI+4]
    CMP AX,0x0200
    JB scrn320			; if (AX < 0x0200) goto scrn320

    MOV CX,VBEMODE
    MOV AX,0x4f01
    INT 0x10

    MOV BX,VBEMODE+0x4000
    MOV AX,0x4f02
    INT 0x10
    MOV AX,0
    MOV AL,[ES:DI+0x19]
    MOV [FS:VMODE],AX
    MOV AX,[ES:DI+0x12]
    MOV [FS:SCRNX],AX
    MOV AX,[ES:DI+0x14]
    MOV [FS:SCRNY],AX
    MOV EAX,[ES:DI+0x28]
    MOV [FS:VRAM],EAX

    MOV DX,[FS:VMODE]
    CALL func_printhex
    JMP $

    JMP enter32

scrn320:
    MOV AL,0x13
    MOV AH,0x00
    INT 0x10
    MOV BYTE[FS:VMODE],8
    MOV WORD[FS:SCRNX],320
    MOV WORD[FS:SCRNY],200
    MOV DWORD[FS:VRAM],0x000a0000



    ; Then, goto 32 bit mode!

enter32:
    JMP skipgdt
ALIGN 16
GDT0:
    DQ 0    ; RESB 8
    ; GDT 1: System Data Segment, AR: 1100(G=4K,D=32) 10010010(0x92,ring0-RW-NoExcute)
    ;        0x00000000-0xffffffff, limit: 0xfffff (*4K)
    DW 0xffff  ; limit 0-15
    DW 0x0000  ; base 0-15
    DB 0x00    ; base 16-23
    DB 0x92    ; AR 0-8
    DB 0xcf    ; AR 9-12(0xc) and limit 16-20(0xf)
    DB 0x00    ; base 24-31
    ; GDT 2: Tmp    Code Segment, AR: 1100(G=4K,D=32) 10011010(0x9a,ring0-ER-NoWrite)
    ;        0x00000000-0xffffffff, limit: 0xfffff (*4K)
    DW 0xffff  ; limit 0-15
    DW 0x0000  ; base 0-15
    DB 0x00    ; base 16-23
    DB 0x9a    ; AR 0-8
    DB 0xcf    ; AR 9-12(0xc) and limit 16-20(0xf)
    DB 0x00    ; base 24-31
    ; GDT 3: SIPL-C Code Segment, AR: 0100(G=1B,D=32) 10011010(0x9a,ring0-ER-NoWrite)
    ;        0x00080000-0x0008ffff, limit: 0x0ffff
    DW 0xffff  ; limit 0-15
    DW 0x0000  ; base 0-15
    DB 0x08    ; base 16-23
    DB 0x9a    ; AR 0-8
    DB 0x40    ; AR 9-12(0x4) and limit 16-20(0x0)
    DB 0x00    ; base 24-31
GDTR0:
    DW 8*4-1
    DD GDT0

skipgdt:
    ;MOV AX,0x8000
    ;MOV GS,AX
    ;MOV SI,enter_c
    ;MOV DI,0
    ;MOV DX,SI
    ;CALL func_printhex
    ;MOV ECX,0
    ;.copyloop:
    ;    MOV AL,[CS:SI]
    ;    MOV [GS:DI],AL
    ;    ADD SI,1
     ;   ADD DI,1
    ;    CMP DI,0
    ;    JNE .copyloop
    ;MOV DX,[CS:enter_c+0x344]
    ;CALL func_printhex
    ;MOV DX,[GS:0x344]
    ;CALL func_printhex
    ;JMP fin

    CLI
    CALL func_waitkbdout
    MOV AL,0xd1
    OUT 0x64,AL
    CALL func_waitkbdout
    MOV AL,0xdf
    OUT 0x60,AL
    CALL func_waitkbdout

    LGDT [GDTR0]
    MOV EAX,CR0
    AND EAX,0x7fffffff ; set bit 31 to 0 (Forbidden paging)
    OR EAX,0x00000001  ; set bit 0  to 1 (Enter protected mode)
    MOV CR0,EAX
    JMP DWORD 2*8:start32













fin:
    HLT
    JMP fin


func_waitkbdout:
    PUSH AX
    .checkloop:
    IN AL,0x64
    AND AL,0x02
    IN AL,0x60
    JNZ .checkloop
    POP AX
    RET

func_checkdisk:
    ; DL = diskid
    ; FS:BX = addr_of_retval(at least 9 Bytes free spaces)
    ; ret:
    ;   BYTE[FS:BX  ] = diskid
    ;   BYTE[FS:BX+1] = max_sector
    ;   BYTE[FS:BX+2] = max_head
    ;   WORD[FS:BX+3] = max_cylinder
    ;  DWORD[FS:BX+5] = total_cylinders
    PUSHA
    MOV [FS:BX],DL

    MOV AH,0x08
    PUSH BX
    PUSH DX
    INT 0x13
    MOV SI,SP    ;
    MOV DL,[SI]  ;
    INC SP       ;
    INC SP       ; POP DL, then ADD SP,2 (don't change CF, so we use INC)
    POP BX
    JC .err
        CALL func_diskinfo_decode
        MOV [FS:BX+1],CL       ; S(byte)
        MOV [FS:BX+2],DH       ; H(byte)
        MOV [FS:BX+3],BP       ; C(word)
        JMP .er_endif
    .err:
        MOV BYTE[FS:BX+1],0
        MOV BYTE[FS:BX+2],0
        MOV WORD[FS:BX+3],0
        JMP .ret
    .er_endif:
    ; Then, calculate total cylinders
    ; Total = (max_c+1) * (max_h+1) * max_s

    MOV EAX,0
    MOV AX,[FS:BX+3]
    INC AX
    MOV ECX,0
    MOV CL,[FS:BX+2]
    INC CX
    IMUL EAX,ECX
    MOV CL,[FS:BX+1]
    IMUL EAX,ECX
    MOV [FS:BX+5],EAX

.ret:
    POPA
    RET




func_printchar:
    ; AL = char
    PUSH AX
    PUSH BX
    MOV AH,0x0e
    MOV BH,0
    MOV BL,15    ; color
    INT 0x10
    POP BX
    POP AX
    RET

func_printhex:
    ; DX = byte, bool DI = do_chline
    PUSH AX
    PUSH BX
    PUSH CX
    MOV CL,12
    .loop:
        PUSH DX
        MOV BX,0x000f
        SHL BX,CL
        AND DX,BX
        SHR DX,CL
        CMP DX,9
        JA .letter
        JMP .number
        .letter:
            ; AL = 'a' + (DX-10)
            MOV AL,'a'
            ADD AL,DL
            SUB AL,10
            JMP .endif
        .number:
            ; AL = '0' + DX
            MOV AL,'0'
            ADD AL,DL
        .endif:
        CALL func_printchar
        POP DX
        CMP CL,0
        JE  .endloop
        SUB CL,4
        JMP .loop
    .endloop:
    CMP DI,0
    JE .ret
        MOV AL,0x0d
        CALL func_printchar
        MOV AL,0x0a
        CALL func_printchar
    .ret:
    POP CX
    POP BX
    POP AX
    RET


func_diskinfo_decode:
    PUSH AX
    MOV AL,CH
    MOV AH,CL
    AND AH,0xc0
    ROR AH,6
    MOV BP,AX
    AND CL,0x3f
    POP AX
    RET


func_diskinfo_encode:
    CMP CL,63
    JA  .fail
    CMP BP,1023
    JA  .fail
    PUSH AX
    AND CL,0x3f
    MOV AX,BP
    AND AH,0x03
    ROL AH,6
    OR  CL,AH
    MOV CH,AL
    POP AX
    RET
    .fail:
    XOR BP,0xffff
    RET







[BITS 32]
start32:
    MOV AX,1*8
    MOV DS,AX
    MOV SS,AX
    MOV ES,AX
    MOV FS,AX
    MOV GS,AX
    MOV ESP,0x120000
    ;fillloop:
    ;MOV ECX,0xa0000
    ;MOV BYTE[ECX],0x0e
    ;INC ECX
    ;CMP ECX,0xffff
    ; Copy enter_c to 0xf0000-0xfffff
    MOV ESI,enter_c
    MOV EDI,0x80000
    MOV ECX,0x4000 ; 0x10000
    CALL func32_memcpy

    MOV EBX,[0x1f006]  ; VRAM
    ;MOV DWORD[EBX],0x00ffffff
    ;MOV DWORD[EBX+4],0x00ff0000
    ;JMP $

    MOV EBX,0x20000  ; The FS Info
    MOV DX,[EBX+0x12]  ; OS Size
    MOV EAX,[EBX+0x14] ; OS Location




    JMP 3*8:0

func32_memcpy:
    ; ESI = source, EDI = dest, ECX = total(unit:DWORD)
    PUSH EAX
    PUSH ESI
    PUSH EDI
    PUSH ECX
    .copyloop:
    MOV EAX,[ESI]
    MOV [EDI],EAX
    ADD ESI,4
    ADD EDI,4
    DEC ECX
    CMP ECX,0
    JNE .copyloop
    POP ECX
    POP EDI
    POP ESI
    POP EAX
    RET

ALIGN 8
enter_c: