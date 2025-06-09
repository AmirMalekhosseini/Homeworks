.data
    input_str:      .asciiz "Hello World"
    rev_buf:        .space 100
    novowel_buf:    .space 100
    pal_msg:        .asciiz "Palindrome\n"
    notpal_msg:     .asciiz "Not a Palindrome\n"
    newline:        .asciiz "\n"
    vowels:         .asciiz "AEIOUaeiou"

.text
.globl main

main:
    la $a0, input_str
    la $a1, rev_buf
    jal reverse_str
    
    li $v0, 4
    la $a0, rev_buf
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    la $a0, input_str
    jal check_palindrome
    
    move $t0, $v0
    li $v0, 4
    beq $t0, 1, print_pal
    la $a0, notpal_msg
    syscall
    j next
    
print_pal:
    la $a0, pal_msg
    syscall
    
next:
    la $a0, input_str
    la $a1, novowel_buf
    jal remove_vowels
    
    li $v0, 4
    la $a0, novowel_buf
    syscall
    
    li $v0, 10
    syscall

# Reverse string using stack method
reverse_str:
    move $t0, $a0
    move $t1, $a1
    
    # Find length
    li $t2, 0
find_len:
    lb $t3, 0($t0)
    beqz $t3, prep_rev
    addiu $sp, $sp, -4
    sw $t3, 0($sp)
    addi $t2, $t2, 1
    addi $t0, $t0, 1
    j find_len

prep_rev:
    beqz $t2, rev_end
pop_chars:
    lw $t3, 0($sp)
    addiu $sp, $sp, 4
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    addi $t2, $t2, -1
    bnez $t2, pop_chars
    
rev_end:
    sb $zero, 0($t1)
    jr $ra

# Palindrome check with optimized comparison
check_palindrome:
    move $t0, $a0
    move $t1, $a0
    li $t3, 0
    
find_end:
    lb $t2, 0($t1)
    beqz $t2, start_check
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    j find_end

start_check:
    li $v0, 1
    addi $t1, $t1, -2
    srl $t4, $t3, 1
    
check_chars:
    blez $t4, pal_done
    lb $t5, 0($t0)
    lb $t6, 0($t1)
    bne $t5, $t6, not_pal
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    addi $t4, $t4, -1
    j check_chars

not_pal:
    li $v0, 0
pal_done:
    jr $ra

# Vowel removal using vowel string
remove_vowels:
    move $t0, $a0
    move $t1, $a1
    la $t9, vowels
    
char_loop:
    lb $t2, 0($t0)
    beqz $t2, rv_done
    
    li $t8, 0
    la $t9, vowels
vowel_check:
    lb $t3, 0($t9)
    beqz $t3, check_vowel
    beq $t2, $t3, skip_char
    addi $t9, $t9, 1
    j vowel_check

check_vowel:
    li $t8, 1
skip_char:
    beqz $t8, save_char
    j next_char

save_char:
    sb $t2, 0($t1)
    addi $t1, $t1, 1

next_char:
    addi $t0, $t0, 1
    j char_loop

rv_done:
    sb $zero, 0($t1)
    jr $ra