.data
    input_buffer_q5a: .space 101
    prompt_q5a:     .asciiz "Input word for case swap: "

.text
.globl main

main:
    li $v0, 4
    la $a0, prompt_q5a
    syscall

    li $v0, 8
    la $a0, input_buffer_q5a
    li $a1, 101
    syscall

    la $t0, input_buffer_q5a    # Current char address

main_loop_q5a:
    lb $t1, 0($t0)
    beq $t1, $zero, end_processing_q5a
    beq $t1, 10, fix_newline_q5a

    li $t3, 'A'
    blt $t1, $t3, try_lowercase_q5a
    li $t3, 'Z'
    bgt $t1, $t3, try_lowercase_q5a
    j perform_case_toggle_q5a

try_lowercase_q5a:
    li $t3, 'a'
    blt $t1, $t3, advance_char_q5a
    li $t3, 'z'
    bgt $t1, $t3, advance_char_q5a

perform_case_toggle_q5a:
    xori $t1, $t1, 0x20         # Toggle case (A-Z <-> a-z)
    sb $t1, 0($t0)

advance_char_q5a:
    addi $t0, $t0, 1
    j main_loop_q5a

fix_newline_q5a:
    sb $zero, 0($t0)            # Null-terminate MARS input

end_processing_q5a:
    li $v0, 4
    la $a0, input_buffer_q5a
    syscall

    li $v0, 11
    li $a0, '\n'
    syscall

    li $v0, 10
    syscall
