       .arch armv8-a

    .text
    .align 2
    .global filter_asm
    .type filter_asm, %function
filter_asm:
// x0 extended
// x1 new_img
// w2 w
// w3 h
// w4 c
// x5 matrix
// w6 m_size

//dfsdfwefwfd
    ret
    add x0, x0, #0
    // w7 line
    mul w7, w2, w4
    // w8 res
    // w9 i
    mov w9, #0
1:
    // w10 j
    mov w10, #0
2:
    // w11 k
    mov w11, #0
3:
    mov w8, #0
    // w12 l
    mov w12, #0
4:
    // w13 y_dif
    mov w13, #1
    sub w13, w13, w6
    add w14, w12, #2
    sdiv    w13, w13, w14
    // w14 m
    mov w14, #0
5:
    // w15 x_dif
    mov w15, #1
    sub w15, w15, w6
    add w16, w14, #2
    sdiv    w15, w15, w16

    // w16 extended[i + 1 + y_dif][(j + 1 + x_dif) * c + k]
    mov x16, #0
    add w16, w13, #1
    add w16, w16, w9
    //ldr x16, [x0, x16]
    mov x17, #0
    add w17, w10, #1
    add w17, w17, w15
    mul w17, w17, w4
    add w17, w17, w11
    add x16, x16, x17
    //ldrb    w16, [x16]
    // w17 matrix[l * m_size + m]
    mov x17, #0

    mul w17, w12, w6
    add w17, w17, w14
    //ldrb    w17, [x5, x17]
    // res += w16 * w17
    mul w16, w16, w17
    add w8, w8, w16

    // m cond
    add w14, w14, #1
    cmp w14, w6
    blt 5b

    // l cond
    add w12, w12, #1
    cmp w12, w6
    blt 4b

    // new_img[i * line + j * c + k] = res
    mov x16, #0
    mul w16, w9, w7
    mul w17, w10, w4
    add w16, w16, w17
    add w16, w16, w11
    //strb    w8, [x1, x16]

    // k cond

    add w11, w11, #1
    cmp w11, #3
    blt 3b

    // if (c == 4)
    cmp w4, #4
    bne 6f
    // w16 extended[i + 1][(j + 1) * c + 3]
    mob x16, #0
    add w16, w9, #1
    //ldr x16, [x0, x16]
    mov x17, #0
    add w17, w10, #1
    mul w17, w17, w4
    add w17, w17, #3
    //ldrb    w16, [x16, x17]

    // new_img[i * line + j * c + 3] = w16
    mov x17, #0
    mul w17, w9, w7
    mul w18, w10, w4
    add w17, w17, w18
    add w17, w17, #3
    //strb    w16, [x1, x17]
6:
    // j cond
    add w10, w10, #1
    cmp w10, w2
    blt 2b

    // i cond
    add w9, w9, #1
    cmp w9, w3
    blt 1b
    ret
    .size   filter_asm, (. - filter_asm)

