.data
    menu_text:      .asciiz "\n\nExit: 0\nPush: 1\nPop: 2\nPrint: 3\nAdd: 4\nMultiply: 5\nDump: 6\nLoad: 7\n\nPlease enter your choice: "
    
    
    
    file_msg:       .asciiz "Filename: "
    err_file:       .asciiz "File error!\n"
    err_format:     .asciiz "Invalid file format!\n"
    err_full:       .asciiz "Stack full!\n"
    err_empty:      .asciiz "Stack empty!\n"
    err_cmd:        .asciiz "Invalid command!\n"
    err_underflow:  .asciiz "Not enough values!\n"
    push_msg:       .asciiz "Value to push: "
    err_overflow:   .asciiz "Overflow occurred!\n"

    temp_word:      .word 0
    file_buffer:    .space 128
   

    cmd_handlers:   .word exit_program, push_val, pop_val, print_stack
                    .word add_vals, mul_vals, save_stack, load_stack

.text
.globl main

main:
    # Initialize stack
    li $v0, 4
    la $a0, push_msg
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0            # $s0 = stack capacity
    
    li $t0, 4
    mul $a0, $s0, $t0
    li $v0, 9
    syscall
    move $s1, $v0            # $s1 = stack base address
    li $s2, 0                # $s2 = stack pointer

main_loop:
    # Display menu
    li $v0, 4
    la $a0, menu_text
    syscall
    
    # Get user choice
    li $v0, 5
    syscall
    
    # Validate input
    bltz $v0, invalid_command
    li $t0, 7
    bgt $v0, $t0, invalid_command
    
    # Jump to handler
    la $t1, cmd_handlers
    sll $t2, $v0, 2
    add $t1, $t1, $t2
    lw $t3, 0($t1)
    jr $t3

invalid_command:
    li $v0, 4
    la $a0, err_cmd
    syscall
    j main_loop

exit_program:
    li $v0, 10
    syscall

push_val:
    # Check stack capacity
    bge $s2, $s0, stack_full
    
    # Get value to push
    li $v0, 4
    la $a0, push_msg
    syscall
    
    li $v0, 5
    syscall
    
    # Store value
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    sw $v0, 0($t0)
    addi $s2, $s2, 1
    j main_loop

stack_full:
    li $v0, 4
    la $a0, err_full
    syscall
    j main_loop

pop_val:
    # Check if stack has elements
    blez $s2, stack_empty
    
    # Pop and display value
    addi $s2, $s2, -1
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    lw $a0, 0($t0)
    
    li $v0, 1
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    j main_loop

stack_empty:
    li $v0, 4
    la $a0, err_empty
    syscall
    j main_loop

print_stack:
    li $t0, 0
print_vals:
    bge $t0, $s2, main_loop
    sll $t1, $t0, 2
    add $t1, $s1, $t1
    lw $a0, 0($t1)
    
    li $v0, 1
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    addi $t0, $t0, 1
    j print_vals

add_vals:
    # Check for at least 2 values
    li $t0, 2
    blt $s2, $t0, underflow_error
    
    # Get top two values
    addi $s2, $s2, -1
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    lw $t1, 0($t0)      # val1
    
    addi $s2, $s2, -1
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    lw $t2, 0($t0)      # val2
    
    # Check for overflow
    addu $t3, $t1, $t2
    xor $t4, $t1, $t2
    bltz $t4, add_store  # Different signs can't overflow
    xor $t4, $t3, $t1
    bltz $t4, overflow_error
    
add_store:
    sw $t3, 0($t0)
    addi $s2, $s2, 1
    j main_loop

mul_vals:
    # Check for at least 2 values
    li $t0, 2
    blt $s2, $t0, underflow_error
    
    # Get top two values
    addi $s2, $s2, -1
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    lw $t1, 0($t0)      # val1
    
    addi $s2, $s2, -1
    sll $t0, $s2, 2
    add $t0, $s1, $t0
    lw $t2, 0($t0)      # val2
    
    # Multiply and store
    mul $t3, $t1, $t2
    sw $t3, 0($t0)
    addi $s2, $s2, 1
    j main_loop

underflow_error:
    li $v0, 4
    la $a0, err_underflow
    syscall
    j main_loop

overflow_error:
    li $v0, 4
    la $a0, err_overflow
    syscall
    j main_loop

save_stack:
    # Get filename
    li $v0, 4
    la $a0, file_msg
    syscall
    
    li $v0, 8
    la $a0, file_buffer
    li $a1, 128
    syscall
    
    # Remove newline
    la $t0, file_buffer
trim_newline_save:
    lb $t1, 0($t0)
    beq $t1, 10, found_nl_save
    beqz $t1, open_file_save
    addi $t0, $t0, 1
    j trim_newline_save
found_nl_save:
    sb $zero, 0($t0)

open_file_save:
    li $v0, 13
    la $a0, file_buffer
    li $a1, 1         # write mode
    li $a2, 0
    syscall
    move $s3, $v0
    bltz $s3, file_error
    
    # Write stack contents
    li $t0, 0
write_loop:
    bge $t0, $s2, close_file_save
    sll $t1, $t0, 2
    add $t1, $s1, $t1
    lw $t2, 0($t1)
    
    sw $t2, temp_word
    li $v0, 15
    move $a0, $s3
    la $a1, temp_word
    li $a2, 4
    syscall
    
    addi $t0, $t0, 1
    j write_loop

close_file_save:
    li $v0, 16
    move $a0, $s3
    syscall
    j main_loop

load_stack:
    # Get filename
    li $v0, 4
    la $a0, file_msg
    syscall
    
    li $v0, 8
    la $a0, file_buffer
    li $a1, 128
    syscall
    
    # Remove newline
    la $t0, file_buffer
trim_newline_load:
    lb $t1, 0($t0)
    beq $t1, 10, found_nl_load
    beqz $t1, open_file_load
    addi $t0, $t0, 1
    j trim_newline_load
found_nl_load:
    sb $zero, 0($t0)

open_file_load:
    li $v0, 13
    la $a0, file_buffer
    li $a1, 0         # read mode
    li $a2, 0
    syscall
    move $s3, $v0
    bltz $s3, file_error
    
    # Read stack contents
    li $s2, 0
read_loop:
    bge $s2, $s0, format_error
    li $v0, 14
    move $a0, $s3
    la $a1, temp_word
    li $a2, 4
    syscall
    beqz $v0, close_file_load
    
    lw $t0, temp_word
    sll $t1, $s2, 2
    add $t1, $s1, $t1
    sw $t0, 0($t1)
    addi $s2, $s2, 1
    j read_loop

close_file_load:
    li $v0, 16
    move $a0, $s3
    syscall
    j main_loop

file_error:
    li $v0, 4
    la $a0, err_file
    syscall
    j main_loop

format_error:
    li $v0, 4
    la $a0, err_format
    syscall
    j main_loop