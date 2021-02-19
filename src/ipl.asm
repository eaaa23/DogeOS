[BITS 16]

MAXSIPLSIZE EQU 63
MAXFAILS EQU 5

diskid EQU 0xff00          ; BYTE
maxhead EQU 0xff01         ; BYTE
maxsector EQU 0xff02       ; BYTE
maxcylinder EQU 0xff03     ; WORD
sipl_size EQU 0xff05       ; WORD
sipl_location EQU 0xff07   ; WORD
sipl_sector EQU 0xff09     ; BYTE
sipl_head EQU 0xff0a       ; BYTE
sipl_cylinder EQU 0xff0b   ; WORD

org 0x7c00
; init stack and segment_registers
    MOV	AX,0
    MOV	SS,AX
	MOV	SP,0x7c00
	MOV	DS,AX
	MOV ES,AX
	MOV FS,AX
	MOV GS,AX

; get info
    MOV [diskid],DL        ; DL was set to right value automatically(by BIOS)
    MOV AH,8          ; Get
    INT 0x13
    CALL func_diskinfo_decode
    MOV [maxsector],CL
    MOV [maxhead],DH
    MOV [maxcylinder],BP


    MOV DI,1
    MOV DX,0

    MOV DL,[diskid]
    CALL func_printhex

    MOV DL,[maxhead]
    CALL func_printhex

    MOV DL,[maxsector]
    CALL func_printhex

    MOV DL,[maxcylinder]
    CALL func_printhex

    ;JMP error


; Booting system

    ; First, read C0-H0-S2 to 0x7e00

    MOV CH,0          ; C
    MOV DH,0          ; H
    MOV CL,2          ; S
    MOV DL,[diskid]   ; diskid
    MOV BX,0x7e0
    MOV ES,BX
    MOV BX,0
    MOV AL,1
    MOV AH,0x02
    INT 0x13
    JNC checkread_ok
    JMP error
    checkread_ok:

    ; Check filesystem
    MOV BX,0
    ; The identifier is 0x5a
checkid_loop:
    MOV AL,[ES:BX]
    CMP AL,0x5a        ; if( *(FS+check_addr) != 0x5a )
    JNE fserror        ;     goto fserror;
    INC BX             ; check_addr += 1;
    CMP BX,8           ; if( check_addr >= 8)
    JB  checkid_loop   ;     break;

    ; Get size & logical location of SIPL
    MOV BX,8
    MOV AX,[ES:BX]     ; SIPL Size
    CMP AX,MAXSIPLSIZE
    JA  fserror
    MOV [sipl_size],AX




    MOV BX,10
    MOV AX,[ES:BX]     ; SIPL Loc
    MOV [sipl_location],AX
    JMP calc_real_location




fserror:
    MOV SI,fserrormsg
    CALL func_printmsg
    JMP error


calc_real_location:
    MOV AX,[sipl_size]
    MOV DX,AX
    CALL func_printhex
    MOV AX,[sipl_location]
    CALL func_logical2physical
    MOV [sipl_sector],CL
    MOV [sipl_head],DH
    MOV [sipl_cylinder],BP


    MOV AL,'F'
    CALL func_printchar

    MOV DI,0
    MOV DL,[diskid]
tryloop:
    MOV AL,'R'
    CALL func_printchar
    MOV AH,0x00
    INT 0x13
    MOV AH,0x02
    MOV AL,1
    MOV BX,0x7e00
    MOV CL,[sipl_sector]
    MOV DH,[sipl_head]
    MOV BP,[sipl_cylinder]
    CALL func_diskinfo_encode
    INT 0x13
    JNC read_finish
    MOV AL,'E'
    CALL func_printchar
    INC DI
    CMP DI,MAXFAILS
    JNA tryloop
    MOV SI,errmsg
    CALL func_printmsg
    JMP error


read_finish:
    MOV DI,1
    MOV DX,BX
    CALL func_printhex
    JMP 0x7e00

error:
    HLT
    JMP error







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




func_printmsg:
    ; SI = start msg address

    ; save changes
    PUSH AX
    PUSH BX
    PUSH SI
.putloop:
    MOV AL,[SI]
    CMP AL,0
    JE .putfin
    CALL func_printchar
    INC SI
    JMP .putloop
.putfin:
    ; reget
    POP SI
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



func_logical2physical:
    ; AX = logical_sector
    ; ret:
    ;   BP = Cylinder
    ;   DH = Head
    ;   CL = sector

    ; Logical = (C*(maxhead+1)+H) * maxsector + S - 1
    ; S = (Logical + 1) % maxsector
    ; N = (Logical + 1) / maxsector
    ;   = (C*(maxhead+1)+H)
    ; H = N % (maxhead+1)
    ; C = N / (maxhead+1)
    PUSH AX
    PUSH BX

    INC AX
    DIV BYTE [maxsector]
    ; After AX/[maxsector]: AL = divided(N), AH = remainder(S)
    MOV CL,AH

    MOV AH,0   ; AX = N
    MOV BL,[maxhead]
    INC BL
    DIV BL
    ; After AX/([maxhead]+1): AL = divided(C), AH = remainder(H)
    MOV DH,AH
    MOV AH,0
    MOV BP,AX

    POP BX
    POP AX
    RET



; diskinfo formats:
; My format:
;  CL = sect
;  DH = head
;  BP = cyl

; std format:
; CH = cyl 0-8 bits
; CL = |  ------  |    --     |
;      L  sect(6)    cyl9-10  H
; DH = head

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




chline:
    DB 0x0d,0x0a  ; 0x0a = '\n', 0x0d = '\r'
    DB 0


errmsg:
    DB "Lerr"
    DB 0

fserrormsg:
    DB "FSerr"
    DB 0


    times 510-($-$$) DB 0
    DB 0x55, 0xaa