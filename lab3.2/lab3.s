    .arch armv8-a
    .data
mes:
    .ascii  "Enter filename: "
    .equ    len, .-mes
filename:
    .skip   1024
buf:
    .skip   1024
newstr:
    .skip   1024
descriptor:
    .skip   8
    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
//Print message
    mov x0, #1
    adr x1, mes
    mov x2, len
    mov x8, #64
    svc #0
//Read filename
    mov x0, #0
    adr x1, filename
    mov x2, #1024
    mov x8, #63
    svc #0
//Owerwrite \n
    adr x1, filename
    sub x0, x0, #1
    strb    wzr, [x1, x0]
//Open file
    mov x0, #-100
    mov x2, #0
    mov x8, #56
    svc #0
    cmp x0, #0
    blt writeerr
    adr x1, descriptor
    str x0, [x1]


    mov x6, #0

reading:
    mov x0, #0
    adr x1, buf
    add x1, x1, x6
    mov x2, #10
    sub x2, x2, x6
    mov x8, #63
    svc #0
    cbnz x0, not_end


not_end:
//Init reading
    adr x1, buf
    add x0, x0, x6
    strb    wzr, [x1, x0]
    adr x3, newstr
    mov x4, x3
//Find word's beginning
0:
    ldrb    w0, [x1], #1
    cbz w0, 5f
    cmp w0, ' '
    beq 0b
	cmp x0, '\t'
	beq 0b
    cmp w0, '\n'
    beq
//Write '\n'
    strb    w0, [x3], #1
    b   0b
1:
//Beginning of word or end of string found
    cmp x4, x3	//x4 - start of buf, x3 - end of start
    beq 2f
//Write separator  between words
   strb	w7, [x3], #1
2:
    sub x2, x1, #1	//x2 - adress of start of word
	mov w9, w0	//first symbol of word
//Find word's end
3:
    ldrb    w0, [x1], #1
    cmp w0, '\n'
    beq 7f
    cmp w0, ' '
    beq 7f
	cmp w0, '\t'
	beq	7f
    cbnz     w0, 3b
//Write word in begining of buffer if it's end
    adr x8, buf
    sub x6, x1, x2
    sub x6, x6, #1
    sub x5, x1, #1	//x5 - adress of end of word
6:
    ldrb    w0, [x2], #1
    strb    w0, [x8], #1
    cmp x5, x2
    bgt 6b
    b   9f
7:
//Else it isn't end of buf
    sub x5, x1, #1
    mov w7, w0
	cmp w7, '\t'
	bne tab
	mov	w7, ' '
tab:
	ldrb	w10, [x5, #-1]!
	cmp w10, w9
	bne 3b
//Write word in new string
8:
    mov x6, #0
    ldrb    w0, [x2], #1
    strb    w0, [x3], #1
    cmp x5, x2
    bge 8b
    b   0b
5:	//separator between strings
    cmp x4, x3
    beq 9f
    strb    w7, [x3], #1
//End of reading, printing new string
9:
    sub x2, x3, x4
    beq reading
    mov x0, #1
    adr x1, newstr
    mov x8, #64
    svc #0
    b   reading
10:
//End
    mov x0, #0
    mov x8, #93
    svc #0
    .size   _start, .-_start
    .type   writeerr, %function
    .data
nofile:
    .string "No such file or directory\n"
    .equ    nofilelen, .-nofile
permission:
    .string "Permission denied\n"
    .equ    permissionlen, .-permission
unknown:
    .string "Unknown error\n"
    .equ    unknownlen, .-unknown
    .text
    .align  2
writeerr:
    cmp x0, #-2
    bne 0f
    adr x1, nofile
    mov x2, nofilelen
    b   2f
0:
    cmp x0, #-13
    bne 1f
    adr x1, permission
    mov x2, permissionlen
    b   2f
1:
    adr x1, unknown
    mov x2, unknownlen
2:
    mov x0, #2
    mov x8, #64
    svc #0

    mov x0, #1
    mov x8, #93
    svc #0
    .size   writeerr, .-writeerr
