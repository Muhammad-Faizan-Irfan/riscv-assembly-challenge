.data
array: .word -10, 20, -30, 40, -50, 60, 10, -20, 30, -40, 50, -65
.equ SIZE, 12
sumMsg: .string "Sum: "
minMsg: .string "\nMinimum Number: "
maxMsg: .string "\nMaximum Number: "
negMsg: .string "\nNegative Count: "

.text
.globl main

main:
    #sum_array
    la a0, array
    li a1, SIZE

    call sum_array

    mv t0, a0
    la a1, sumMsg
    li a0, 4
    ecall

    mv a1, t0
    li a0, 1
    ecall
    
    #find_min
    la a0, array
    li a1, SIZE

    call find_min

    mv t0, a0
    la a1, minMsg
    li a0, 4
    ecall

    mv a1, t0
    li a0, 1
    ecall
    
    #find_max
    la a0, array
    li a1, SIZE

    call find_max

    mv t0, a0
    la a1, maxMsg
    li a0, 4
    ecall

    mv a1, t0
    li a0, 1
    ecall

    #count_negative

    la a0, array
    li a1, SIZE

    call count_neg

    mv t0, a0
    la a1, negMsg
    li a0, 4
    ecall

    mv a1, t0
    li a0, 1
    ecall
   
    
    #exit
    li a0, 10
    ecall

 
#sum_function
sum_array:

    addi sp, sp, -16
    sw s0, 12(sp)
    
    mv s0, a0
    
    li t0, 0 #Sum
    li t1, 0 #Current index
    
sum_loop:

    bge t1, a1, sum_exit
    lw t2, 0(s0)
    add t0, t0, t2
    addi s0, s0, 4
    addi t1, t1, 1
    j sum_loop
    
sum_exit:
    mv a0, t0
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
    
#find min function    
find_min:

    addi sp, sp, -16
    sw s0, 12(sp)
    
    mv s0, a0
    
    li t0, 0 #min
    li t1, 0 #Current index
    
min_loop:

    bge t1, a1, min_exit
    lw t2, 0(s0)
    bge t2, t0, min_skip
    mv t0, t2
    addi s0, s0, 4
    addi t1, t1, 1
    j min_loop

min_skip:

    addi s0, s0, 4
    addi t1, t1, 1
    j min_loop
    
min_exit:
    mv a0, t0
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
   
#find_max function
find_max:

    addi sp, sp, -16
    sw s0, 12(sp)
    
    mv s0, a0
    
    li t0, 0 #max
    li t1, 0 #Current index
    
max_loop:

    bge t1, a1, max_exit
    lw t2, 0(s0)
    ble t2, t0, max_skip
    mv t0, t2
    addi s0, s0, 4
    addi t1, t1, 1
    j max_loop

max_skip:

    addi s0, s0, 4
    addi t1, t1, 1
    j max_loop
    
max_exit:
    mv a0, t0
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
    
    
# count negative function    
count_neg:

    addi sp, sp, -16
    sw s0, 12(sp)
    
    mv s0, a0
    
    li t0, 0 #neg
    li t1, 0 #Current index
    
neg_loop:

    bge t1, a1, neg_exit
    lw t2, 0(s0)
    bge t2, zero, neg_skip
    addi t0, t0, 1
    addi s0, s0, 4
    addi t1, t1, 1
    j neg_loop

neg_skip:

    addi s0, s0, 4
    addi t1, t1, 1
    j neg_loop
    
neg_exit:
    mv a0, t0
    lw s0, 12(sp)
    addi sp, sp, 16
    ret
