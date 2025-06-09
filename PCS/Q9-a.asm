.data
    menu_prompt:    .asciiz "Select option (0-3):\n0: Exit\n1: Print char\n2: Print int\n3: Print float\n> "
    char_msg:       .asciiz "Random char: Q\n"
    int_msg:        .asciiz "Random int: 42\n"
    float_msg:      .asciiz "Random float: 2.71\n"
    
    # Jump table with different organization
    jmp_table:      .word case_exit, case_char, case_int, case_float

.text
.globl main

main:
    # Main program loop
    main_loop:
        # Display menu
        li $v0, 4
        la $a0, menu_prompt
        syscall
        
        # Get user input
        li $v0, 5
        syscall
        
        # Validate input range
        bltz $v0, main_loop
        li $t0, 3
        bgt $v0, $t0, main_loop
        
        # Jump to selected case
        la $t1, jmp_table
        sll $t2, $v0, 2
        addu $t1, $t1, $t2
        lw $t3, 0($t1)
        jr $t3

# Case handlers with different implementations
case_exit:
    li $v0, 10
    syscall

case_char:
    li $v0, 4
    la $a0, char_msg
    syscall
    j main_loop

case_int:
    li $v0, 4
    la $a0, int_msg
    syscall
    j main_loop

case_float:
    li $v0, 4
    la $a0, float_msg
    syscall
    j main_loop