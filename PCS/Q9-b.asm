.data
    menu_prompt:    .asciiz "Select operation (0-3):\n0: Exit\n1: Show char\n2: Show int\n3: Show float\n> "
    char_display:   .asciiz "Generated char: A\n"
    int_display:    .asciiz "Random int: 99\n"
    float_display:  .asciiz "Approx float: 1.61\n"
    
    # Call table organized differently
    func_table:     .word print_char, print_int, print_float

.text
.globl main

main:
    program_loop:
        # Display menu options
        li $v0, 4
        la $a0, menu_prompt
        syscall
        
        # Get user selection
        li $v0, 5
        syscall
        
        # Handle exit case first
        beqz $v0, program_exit
        
        # Validate input range 1-3
        li $t0, 1
        blt $v0, $t0, program_loop
        li $t0, 3
        bgt $v0, $t0, program_loop
        
        # Calculate function pointer offset (index - 1)
        addi $t1, $v0, -1
        sll $t1, $t1, 2
        
        # Load and call function
        la $t2, func_table
        add $t2, $t2, $t1
        lw $t3, 0($t2)
        jalr $t3
        
        # Continue loop
        j program_loop

program_exit:
    li $v0, 10
    syscall

# Function implementations with different structure
print_char:
    li $v0, 4
    la $a0, char_display
    syscall
    jr $ra

print_int:
    li $v0, 4
    la $a0, int_display
    syscall
    jr $ra

print_float:
    li $v0, 4
    la $a0, float_display
    syscall
    jr $ra