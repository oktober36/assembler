	.arch armv8-a
//	res = a*c/b + d*b/e - c*c/a*d
	.data
	.align	3
str:
	.byte	21
nstr:
    .byte   21

	.text
	.align	2
	.global _start
	.type	_start, %function
_start:

    mov x0, #8
    mov x1, #-630
     mov x2,#-895
     mov x3,#-799
     mov x4, #-428
     mov x5,#-802
     mov x6,#-952
     mov x7,#-42
     mov x8,#-727

    sub sp, sp, #80
    stp x1, x2, [sp]
    stp x3, x4, [sp, #16]
    stp x5, x6, [sp, #32]
    stp x7, x8, [sp, #48]
    stp x9, x10, [sp, #64]

    mov x5, x15

    // x18 max

    mov x18, #0

    // x17 max sum

    mov x17, #0

    // x11 i

    mov x11, #0
1:


    //x13 j
    add x13, x11, #1
2:
    cmp x13, x0
    bge 3f

      // x12 num1
    ldr x12, [sp, x11, lsl#3]
    cmp x12, #0
    mov x6, #-1
    bge 11f
    smull   x12, w12, w6
11:

    // x14 num2
    ldr x14, [sp, x13, lsl#3]

    cmp x14, #0
    bge 10f
    smull   x14, w14, w6
10:
    add x8, x12, x14
    //Algos

    mov x15, #0
4:
    cbz x12, 5f
    cbz x14, 5f
    mov x16, #10
    udiv x1, x12, x16
    udiv x2, x14, x16
    mul x1, x1, x16
    mul x2, x2, x16
    sub x1, x12, x1
    sub x2, x14, x2
    cmp x1, x2

    bne 6f
    add x15, x15, #1
6:
    udiv x12, x12, x16
    udiv x14, x14, x16
    b   4b
5:
    cmp x15, x18
    ble 7f
    mov x17, x8
    mov x18, x15
7:

    cmp x15, x18
    bne 22f
    cmp x8, x17
    blt 22f
    mov x17, x8
22:

    add x13, x13, #1
    b   2b
3:
    add x11, x11, #1
    cmp x11, x0
    blt  1b
    mov x0, x17
    mov sp, x5

	.size	_start, .-_start
