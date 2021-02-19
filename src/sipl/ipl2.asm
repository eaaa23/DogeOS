[BITS 16]

diskid EQU 0xff00          ; BYTE
maxhead EQU 0xff01         ; BYTE
maxsector EQU 0xff02       ; BYTE
maxcylinder EQU 0xff03     ; WORD
sipl_size EQU 0xff05       ; WORD
sipl_location EQU 0xff07   ; WORD
sipl_sector EQU 0xff09     ; BYTE
sipl_head EQU 0xff0a       ; BYTE
sipl_cylinder EQU 0xff0b   ; WORD


org 0x7e00
    CALL get_ip_dx
    JMP entry
get_ip_dx:
    MOV SI,SP
    MOV DX,[SI]
    RET
entry:
    CALL func_printhex
    MOV AL,'H'
    CALL func_printchar

    ; AL = read once sector total
    ; AH = 0x02 / 0x00
    ; CL = sect - 1
    ; CH = counter(least)
    ; DL = diskid
    ; DH = head
    ; BP = cyl
    ; BX = 0x8000 ~ 0xfe00
    ; ES = 0
    ; DI = tempval
    ; SI = errors
    MOV CL,[sipl_sector]
    SUB CL,1
    MOV CH,[sipl_size]
    MOV DL,[diskid]
    MOV DH,[sipl_head]
    MOV BP,[sipl_cylinder]
    MOV BX,0
    MOV ES,BX
    MOV BX,0x8000
    MOV SI,0


    readloop:

        PUSHA   ; for error handling
        MOV AH,0x00
        INT 0x13
        MOV AH,0x02
        ; Calc AL
        MOV AL,[maxsector]

        SUB AL,CL      ; AL = most_can_read_this_time
        CMP CH,AL
        JA  .skip0     ; if most_can_read_this_time(AL) > we_need_to_read(CH), AL=CH
            MOV AL,CH
        .skip0:
        PUSH AX  ; This will change in INT 0x13
        PUSH CX  ; These three will change in diskinfo encoding
        PUSH DX
        PUSH BP
            INC CL
                PUSHA
                MOV DI,0
                MOV SI,DX
                MOV DH,0

                PUSH AX
                MOV AL,'D'
                CALL func_printchar
                CALL func_printhex

                MOV AL,'T'
                CALL func_printchar
                POP AX
                MOV DL,AL
                CALL func_printhex



                MOV AL,'C'
                CALL func_printchar
                MOV DX,BP
                CALL func_printhex

                MOV AL,'H'
                CALL func_printchar
                MOV DX,SI
                MOV DL,DH
                MOV DH,0
                CALL func_printhex

                MOV AL,'S'
                CALL func_printchar
                MOV DH,0
                MOV DL,CL
                CALL func_printhex

                MOV AL,'A'
                CALL func_printchar
                MOV DX,BX
                CALL func_printhex

                MOV AL,'N'
                CALL func_printchar
                MOV DH,0
                MOV DL,CH
                CALL func_printhex

                MOV AL,0x0d
                CALL func_printchar
                MOV AL,0x0a
                CALL func_printchar

                POPA
            CALL func_diskinfo_encode
            INT 0x13
            JNC noexcept
            CMP SI,5
            JBE continue
            JMP error
            continue:
                ADD SP,8
                MOV AL,'E'
                CALL func_printchar
                POPA
                INC SI
                JMP readloop
        noexcept:
        POP BP
        POP DX
        POP CX
        POP AX
        SUB CH,AL
        JZ  readend
        MOV DI,AX    ;
        AND DI,0xff  ; DI = AL
        ROL DI,9     ; DI = AL*512
        ADD BX,DI    ; BX += AL*512

        ; Then, change CL,DH,CH
        PUSH BX      ; borrow

        MOV BL,[maxsector]
        ADD CL,AL
        CMP CL,BL
        JB  skip_no_reset_sector
        SUB CL,BL
        INC DH
        skip_no_reset_sector:

        MOV BL,[maxhead]
        INC BL
        CMP DH,BL
        JB  skip_no_reset_head
        SUB DH,BL
        INC BP
        skip_no_reset_head:
        POP BX
        CMP BP,[maxcylinder]
        JBE no_out_of_range
        JMP error
        no_out_of_range:
        ADD SP,16        ; According to PUSHA
        JMP readloop
    readend:
        MOV AL,'H'
        CALL func_printchar
        MOV DX,[0x8200]
        CALL func_printhex
        MOV DX,DS
        CALL func_printhex
        MOV DX,CS
        CALL func_printhex
        JMP 0:0x8200




error:
    MOV AL,'e'
    CALL func_printchar
    erloop:
    HLT
    JMP erloop



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

    times 512-($-$$) DB 0