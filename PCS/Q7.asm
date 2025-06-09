.data
    input_msg:    .asciiz "Enter n for f(n)=2*f(n-1) + f(n-2)/2 [f(0)=1, f(1)=2]: "
    output_msg:   .asciiz "f(n) =  "
    line_break:   .asciiz "\n"
    float_one:    .float 1.0
    float_two:    .float 2.0

.text
.globl main

main:

    li $v0, 4
    la $a0, input_msg
    syscall


    li $v0, 5
    syscall
    move $s0, $v0       

    # Calculate recursive function
    move $a0, $s0
    jal recursive_func


    li $v0, 4
    la $a0, output_msg
    syscall

    li $v0, 2
    mov.s $f12, $f0
    syscall

    li $v0, 4
    la $a0, line_break
    syscall

    # Terminate program
    li $v0, 10
    syscall

# Recursive function implementation
recursive_func:

    beqz $a0, return_one
    li $t0, 1
    beq $a0, $t0, return_two


    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $a0, 8($sp)

    # First recursive call (n-1)
    addi $a0, $a0, -1
    jal recursive_func
    swc1 $f0, 4($sp)    # Store f(n-1)

    # Second recursive call (n-2)
    lw $a0, 8($sp)
    addi $a0, $a0, -2
    jal recursive_func
    swc1 $f0, 0($sp)    # Store f(n-2)

    # Restore context
    lw $ra, 12($sp)
    lw $a0, 8($sp)
    lwc1 $f1, 4($sp)    # f(n-1)
    lwc1 $f2, 0($sp)    # f(n-2)

    # Perform calculations
    lwc1 $f3, float_two
    mul.s $f1, $f1, $f3  # 2*f(n-1)
    div.s $f2, $f2, $f3  # f(n-2)/2
    add.s $f0, $f1, $f2  # Final result


    addi $sp, $sp, 16
    jr $ra

return_one:
    lwc1 $f0, float_one
    jr $ra

return_two:
    lwc1 $f0, float_two
    jr $ra