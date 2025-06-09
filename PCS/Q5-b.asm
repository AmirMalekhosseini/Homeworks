.data
    input_str_q5b:  .space 101
    prompt_msg_q5b: .asciiz "Enter word to make lowercase: "

.text
.globl main

main:
    li $v0, 4
    la $a0, prompt_msg_q5b
    syscall

    li $v0, 8
    la $a0, input_str_q5b
    li $a1, 101                 # Max string length
    syscall

    la $a0, input_str_q5b
    jal convert_to_lower_sub    # Call conversion routine

    li $v0, 4
    la $a0, input_str_q5b
    syscall

    li $v0, 11
    li $a0, '\n'
    syscall

    li $v0, 10
    syscall

# Subroutine: convert_to_lower_sub
# $a0: address of string to be modified
convert_to_lower_sub:
    addi $sp, $sp, -4
    sw $s0, 0($sp)              # Preserve $s0

    move $s0, $a0               # $s0 is our string pointer

char_process_loop_q5b:
    lb $t1, 0($s0)
    beq $t1, $zero, end_sub_q5b
    beq $t1, 10, newline_handler_q5b # MARS appends newline

    # Check if character is uppercase ('A' - 'Z')
    li $t2, 'A'
    blt $t1, $t2, next_iteration_q5b
    li $t2, 'Z'
    bgt $t1, $t2, next_iteration_q5b

    xori $t1, $t1, 0x20         # Flip to lowercase if 'A'-'Z'
    sb $t1, 0($s0)

next_iteration_q5b:
    addi $s0, $s0, 1
    j char_process_loop_q5b

newline_handler_q5b:
    sb $zero, 0($s0)            # Replace newline with null

end_sub_q5b:
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    jr $ra