.data
    msg_deg1:       .asciiz "Enter first polynomial degree (max 10): "
    msg_deg2:       .asciiz "Enter second polynomial degree (max 10): "
    msg_coeff:      .asciiz "Enter coeff for x^"
    msg_result:     .asciiz "\nProduct polynomial:\n"
    msg_degree:     .asciiz "Degree: "
    msg_coeff_val:  .asciiz "Coeff for x^"
    colon:          .asciiz ": "
    nl:             .asciiz "\n"
    err_msg:        .asciiz "Invalid degree! Must be ?10\n"

    polyA:          .space 44
    polyB:          .space 44
    product:        .space 84
    degA:           .word 0
    degB:           .word 0

.text
.globl main

main:
    # Get polynomial A
    jal get_poly
    sw $v0, degA
    
    # Get polynomial B
    jal get_poly
    sw $v0, degB
    
    # Multiply polynomials
    la $a0, polyA
    lw $a1, degA
    la $a2, polyB
    lw $a3, degB
    jal poly_multiply
    
    # Display result
    jal show_result
    
    li $v0, 10
    syscall

# Subroutine to input polynomial
get_poly:
    li $t0, 10
input_degree:
    li $v0, 4
    la $a0, msg_deg1
    syscall
    
    li $v0, 5
    syscall
    
    bgt $v0, $t0, invalid_deg
    bltz $v0, invalid_deg
    move $t1, $v0
    
    # Input coefficients
    li $t2, 0
    la $t3, polyA
    beqz $s0, input_coeffs
    la $t3, polyB
    
input_coeffs:
    bgt $t2, $t1, done_input
    
    li $v0, 4
    la $a0, msg_coeff
    syscall
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, colon
    syscall
    
    li $v0, 5
    syscall
    
    sw $v0, 0($t3)
    addi $t3, $t3, 4
    addi $t2, $t2, 1
    j input_coeffs
    
invalid_deg:
    li $v0, 4
    la $a0, err_msg
    syscall
    j input_degree
    
done_input:
    move $v0, $t1
    li $s0, 1
    jr $ra

# Polynomial multiplication subroutine
poly_multiply:
    # Initialize product array to zero
    li $t0, 0
    la $t1, product
clear_product:
    sw $zero, 0($t1)
    addi $t1, $t1, 4
    addi $t0, $t0, 1
    blt $t0, 21, clear_product
    
    # Perform multiplication
    li $t0, 0  # i
mult_outer:
    bgt $t0, $a1, mult_done
    
    li $t1, 0  # j
mult_inner:
    bgt $t1, $a3, inner_done
    
    # Get polyA[i]
    sll $t2, $t0, 2
    add $t2, $a0, $t2
    lw $t3, 0($t2)
    
    # Get polyB[j]
    sll $t4, $t1, 2
    add $t4, $a2, $t4
    lw $t5, 0($t4)
    
    # Calculate product term position
    add $t6, $t0, $t1
    sll $t6, $t6, 2
    la $t7, product
    add $t7, $t7, $t6
    
    # Multiply and accumulate
    mul $t8, $t3, $t5
    lw $t9, 0($t7)
    add $t8, $t8, $t9
    sw $t8, 0($t7)
    
    addi $t1, $t1, 1
    j mult_inner
    
inner_done:
    addi $t0, $t0, 1
    j mult_outer
    
mult_done:
    jr $ra

# Display result subroutine
show_result:
    li $v0, 4
    la $a0, msg_result
    syscall
    
    # Calculate result degree
    lw $t0, degA
    lw $t1, degB
    add $t2, $t0, $t1
    
    li $v0, 4
    la $a0, msg_degree
    syscall
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, nl
    syscall
    
    # Print coefficients
    li $t3, 0
print_loop:
    bgt $t3, $t2, print_done
    
    li $v0, 4
    la $a0, msg_coeff_val
    syscall
    
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, colon
    syscall
    
    sll $t4, $t3, 2
    la $t5, product
    add $t5, $t5, $t4
    lw $a0, 0($t5)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, nl
    syscall
    
    addi $t3, $t3, 1
    j print_loop
    
print_done:
    jr $ra