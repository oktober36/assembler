	.arch armv8-a
	.data
	.align	3
y:
    .byte   3
x:
	.byte   5
mas:
	.byte  -1, -2,-3, -4, -5
    .byte   1, 2, 3, 4, 5
    .byte   1, 2, 3, 4, 5
nmas:
    .skip   3 * 5
sharr:
    .byte   3
shmax:
    .byte   1

	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
    adr     x0, mas
    mov     x21, comp

    adr     x3, y
    mov     x1, #0
    ldrb    w1, [x3]

    adr     x3, x
    mov     x2, #0
    ldrb    w2, [x3]

//Summing

//save sp
    mov     x20, sp
//allocate stack memory
    lsr     x4, x2, #2
    add     x4, x4, #1
    lsl     x4, x4, #4
    sub     sp, sp, x4

//init sum array
//column counter
    mov     x4, #0
1:
//for addresing
    mov     x5, x4
//line counter
    sub     x6, x1, #1
//summ
    mov     x7, #0
2:
    ldrsb   w8, [x0, x5]
    add     w7, w7, w8
    add     x5, x5, x2
    subs    x6, x6, #1
    bge     2b

//change order
    cbz     x21, skip
    mov     w8, #0
    sub     w7, w8, w7
skip:
    str     w7, [sp, x4, lsl#2]
    add     x4, x4, #1
    cmp     x2, x4
    bne     1b
//save sum array pointer
    mov     x3, sp

//Init pointer array

//allocate stack memory
    lsr     x5, x2, #1
    add     x5, x5, #1
    lsl     x5, x5, #4
    sub     sp, sp, x5
//init
    mov     x5, #0
3:
    add     x6, x0, x5
    str     x6, [sp, x5, lsl#3]
    add     x5, x5, #1
    cmp     x5, x2
    bne     3b

//Sorting

//shell max
    mov     x14, #0
    adr     x4, shmax
    ldrb    w14, [x4]
//shell counter
    mov     x4, #0
//shell len
    mov     x5, #0
4:
    adr     x6, sharr
    ldrb    w5, [x6, x4]
//shell position counter
    mov     x6, #0
//fixed  counter
5:
    mov     x7, x6
6:
    add     x7, x7, x5
    cmp     x7, x2
    bge     9f
//fixed numb
    ldr     w8, [x3, x7, lsl#2]
//fixed pointer
    ldr     x12, [sp, x7, lsl#3]
//counter 1
    mov     x9, x7
7:
    mov     x10, x9
    cmp     x6, x9
    beq     8f
    sub     x9, x9, x5
//cur number
    ldr     w11, [x3, x9, lsl#2]
//current coulumn pointer
    ldr     x13, [sp, x9, lsl#3]
//comparing
    cmp     x8, x11
    bge     8f
//move right
    str     w11, [x3, x10, lsl#2]
    str     x13, [sp, x10, lsl#3]
    b       7b
8:
//begin of array
    str     w8, [x3, x10, lsl#2]
    str     x12, [sp, x10, lsl#3]
    b       6b
9:
    add     x6, x6, #1
    cmp     x5, x6
    bgt     5b
//end sort in shels, shange it
    add     x4, x4, #1
    cmp     x14, x4
    bgt     4b
//end sorting
    cmp     x5, #1
    beq     10f
    mov     x5, #1
    mov     x6, #0
    b       5b

//Relocating

10:
//x counter
    mov     x5, #0
//nmas pointer
    adr     x8, nmas
11:
    ldr     x9, [sp, x5, lsl#3]
//y counters
    mov     x6, x1
    mov     x7, #0
12:

    ldrsb   w10, [x9, x7]
    strb   w10, [x8, x7]
    add     x7, x7, x2
    subs    x6, x6, #1
    bne     12b
    add     x5, x5, #1
    add     x8, x8, #1
    cmp     x5, x2
    bne     11b

//Copying
    adr     x8, nmas
//counter
    umull   x5, w1, w2
13:
    subs    x5, x5, #1
    ldrsb   w6, [x8, x5]
    strb   w6, [x0, x5]
    bne     13b
//Ending
    mov     sp, x20
    mov     x0, #0
    mov     x8, #93
    svc     #0

    .size   _start, .-_start
