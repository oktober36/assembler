    .arch armv8-a
	.data

   	.text
   	.align 2
	.global decomposition_asm
    .type decomposition_asm, %function
    //x0 - img, x1 - new_img, x2 - img_s x10 - w, x11 - h x3 - channel

decomposition_asm:
    mov x10, x2
    mov x11, x3
    mov x3, x4

    mov x6, #3
    mul x2, x10, x11
    mul x2, x2, x6

    //x5 i
    mov x5, #0
1:
    //w6 r w7 g w8 b
    ldrb    w6, [x0, x5]
    add x5, x5, #1
    ldrb    w7, [x0, x5]
    add x5, x5, #1
    ldrb    w8, [x0, x5]
    sub x5, x5, #2


    //x12 w * channels
    mul x12, x10, x3
    //x13 lvl
    udiv    x13, x5, x12
    // if ( i % (w * channels) > (w*channels * lvl / h) )
    // i % (w * channels) = i - lvl * (w * channels)
    mul x14, x13, x12
    sub x14, x5, x14
    mul x15, x12, x13
    udiv    x15, x15, x11
    cmp x14, x15
    ble 6f

    // r, g, b copy
    strb w6, [x1, x5]
    add x5, x5, #1
    strb w7, [x1, x5]
    add x5, x5, #1
    strb w8, [x1, x5]
    sub x5, x5, #2

    b 5f
6:



    //w9 max
    cmp w6, w7
    ble 2f
    cmp w6, w8
    ble 2f
    mov w9, w6
    b   4f
2:
    cmp w7, w8
    ble 3f
    mov w9, w7
    b   4f
3:
    mov w9, w8
4:
//Saving
    strb w9, [x1, x5]
    add x5, x5, #1
    strb w9, [x1, x5]
    add x5, x5, #1
    strb w9, [x1, x5]
    sub x5, x5, #2

//4th chanell
    cmp x3, #4
    bne 5f
    add x5, x5, #3
    ldrb w9, [x0, x5]
    strb w9, [x1, x5]
    sub x5, x5, #3
5:
//Cycle condition
    add x5, x5, x3
    cmp x5, x2
    ble 1b
    mov x0, x1
    ret
    .size decomposition_asm, .-decomposition_asm
