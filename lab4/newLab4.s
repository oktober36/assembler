        .arch armv8-a
    .data
x_rmes:
	.string	"Input x (|x| < 1))\n"
a_rmes:
    .string "Input a\n"
d_rmes:
    .string "Input d (d > 0)\n"
float_form:
	.string	"%f"
func_mes:
	.string	"(1 + %.8f)^%f= %.8f\n"
myfunc_mes:
	.string	"Taylor series(%.8f)= %.8f\n"
file_mes:
    .string "a%d = %.8f\n"
usage_emes:
	.string "Usage: %s output_filename\n"
eof_emes:
    .string "EOF"
mode:
    .string "w"

    .text
    .align	2
    .global	main
	.type	main, %function
	.equ	x, 16
    .equ    a, 20
    .equ    d, 24
    .equ    progname, 32
    .equ    filename, 40
    .equ    fp, 48
main:

    sub	sp, sp, #64
	stp	x29, x30, [sp]
check_params:
    cmp	w0, #2
	beq	open_file
	ldr	x2, [x1]
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, usage_emes
	bl	fprintf
	mov	w0, #1
    b   exit
open_file:
    ldr x0, [x1]
    str x0, [sp, progname]
    ldr x0, [x1, #8]
    str x0, [sp, filename]
    adr x1, mode
    bl fopen
    cbnz x0, requests
    ldr x0, [sp, filename]
    bl perror
    mov w0, #1
    b exit
requests:
// Push fp
    str x0, [sp, fp]
request_x:
    adr x0, x_rmes
    bl printf
// Scan x
    adr x0, float_form
    add x1, sp, x
    bl scanf
// EOF check
    cmp w0, #0
    blt eof
// |x| < 1
    ldr s0, [sp, x]
    fabs s0, s0
    fmov s1, #1.0
    fcmp s0, s1
// If x is invalid request it again
    bge request_x

request_a:
    adr x0, a_rmes
    bl printf
// Scan a
    adr x0, float_form
    add x1, sp, a
    bl scanf
    cmp w0, #0
// EOF check
    blt eof
request_d:
    adr x0, d_rmes
    bl printf
// Scan d
    adr x0, float_form
    add x1, sp, d
    bl scanf
    cmp w0, #0
// Eof check
    blt eof
// d > 0
    ldr s0, [sp, d]
    fcmp s0, #0.0
    ble request_d

// Calculate func
    ldr s0, [sp, x]
    fmov s1, #1.0
    fadd s0, s0, s1
    ldr s1, [sp, a]
    bl powf


// Print func
    fcvt d2, s0
    ldr s0, [sp, x]
    fcvt d0, s0
    ldr s1, [sp, a]
    fcvt d1, s1
    adr x0, func_mes
    bl printf

// Calculate myfunc
    ldr s0, [sp, x]
    ldr s1, [sp, a]
    ldr s2, [sp, d]
    ldr x0, [sp, fp]
    bl myfunc

    adr x0, myfunc_mes
    fcvt d1, s0
    ldr s0, [sp, x]
    fcvt d0, s0
    bl printf
//Close file
    ldr x0, [sp, fp]
    bl fclose
//Finish
    mov w0, #0
    b exit

eof:
    mov x0, #0
    mov w1, #0
    adr x2, eof_emes
    mov w0, #1
    bl error
exit:
    ldp x29, x30, [sp]
    add sp, sp, #64
    ret
    .size main, .-main



    .global	myfunc
	.type	myfunc, %function
	.equ    fp1, 16
	.equ    i, 24
myfunc:
    sub	sp, sp, #128
    stp	x29, x30, [sp]

	str x0, [sp, fp1]

	stp	s27, s28, [sp, #24]
	stp	s25, s26, [sp, #40]
	stp	s23, s24, [sp, #56]
	stp s21, s22, [sp, #72]
    str s20, [sp, #88]

// s20 x
    fmov s20, s0
// s21 alf
    fmov s21, s1
// s22 d
    fmov s22, s2
// s15 #1.0
    fmov s15, #1.0
// x5 fp1
    mov x5, x0

// s23, x6 i
    fmov s23, #1.0
    mov x6, #1
    str x6, [sp, i]
// s24 ai
    fmul s24, s20, s21
// s25 res
    fadd s25, s24, s15

// Load a1 to file

    ldr x0, [sp, fp1]
    adr x1, file_mes
    mov x2, #1
    fcvt d0, s24
    bl  fprintf

1:
// alf -= 1
    fsub s21, s21, s15
// i += 1
    ldr x6, [sp, i]
    add x6, x6, #1
    str x6, [sp, i]
    fadd s23, s23, s15
// s26 ai+1
    fmul s26, s24, s21
    fdiv s26, s26, s23
// s27 |ai+1 - ai|
    //fsub s27, s26, s24
    //fabs s27, s27
    //fcmp s27, s22

// ai+1 < d
    fcmp s24, s22
    ble 2f
// Load ai+1 to file
    ldr x0, [sp, fp1]
    adr x1, file_mes
    mov x2, x6
    fcvt d0, s26
    bl  fprintf
// Res += ai+1
    fadd s25, s25, s26
    fmov s24, s26
    b   1b
2:
    fmov s0, s25

    ldp	x29, x30, [sp]
	ldp	s27, s28, [sp, #24]
	ldp	s25, s26, [sp, #40]
	ldp	s23, s24, [sp, #56]
	ldp s21, s22, [sp, #72]
	ldr s20, [sp, #88]
    add sp, sp, #128
    ret
    .size myfunc, .-myfunc





