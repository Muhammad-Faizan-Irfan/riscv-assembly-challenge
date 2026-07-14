.data
cache: .space 200 #(integers)50 *4 = 200
printstart: .string "fib("
printend: .string ") = "

.text 
.globl main
main: 
    
    #store adress in a0 for initialization 
    la   a0, cache
    call initialize_array
    
    #call fib at 12 = Fib(20)
    li   a0, 20
    call print_start
    li   a0, 20
    call fib

    # print result
    mv   a1, a0
    li   a0, 1
    ecall
    
    # print newline
    li   a1, '\n'
    li   a0, 11
    ecall    
    
    #call fib at 12 = Fib(10)
    li   a0, 10
    call print_start
    li   a0, 10
    call fib

    # print result
    mv   a1, a0
    li   a0, 1
    ecall
    
    # print newline
    li   a1, '\n'
    li   a0, 11
    ecall
        
    
    #call fib at 12 = Fib(15)
    li   a0, 15
    call print_start
    li   a0, 15
    call fib

    # print result
    mv   a1, a0
    li   a0, 1
    ecall
    
    # print newline
    li   a1, '\n'
    li   a0, 11
    ecall
    
    
    #exit
    li   a0, 10
    ecall
    
#print_start(n):
print_start:

    #print Fib(
    mv   t0, a0 
    la   a1, printstart
    li   a0, 4
    ecall
    
    #print n
    mv   a1, t0
    li   a0, 1
    ecall
    
    #print ) = 
    la   a1, printend
    li   a0, 4
    ecall
    
    ret
    
initialize_array:
    #initilize cache array to -1 
    li   t0, 50
    mv   t1, a0
    for_init:
        
        blez t0, init_done
        li   t2, -1
        sw   t2, 0(t1)
        addi t1, t1, 4
        addi t0, t0, -1
        j    for_init
       
    init_done:
        ret
        
#fib(n);a0 = n       
fib:

    # PROLOGUE — save callee-saved regs + ra
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    sw   s4, 8(sp)
    sw   s5, 4(sp)
    sw   s6, 0(sp)
    
    mv   s0, a0   # s0 = n (preserved across call)
    
    
    

    
    #check base case
    li   t0, 0
    li   t1, 1
    beq  s0, t0, base_case_0
    beq  s0, t1, base_case_1
    
    
    #check cache
    la   s1, cache   #s1 = &cache[0]
    slli s2, s0, 2 #s2 = n * 4 
    add  s3, s2, s1 #s3 = &cache[n]
    lw   s4, 0(s3)   #s4 = cache[n]
   
    #check if in cache
    li   t0, -1
    bne  s4, t0, cache_hit #if exist in cache return from there
    
    #calc fib(n-1)
    addi t2, s0, -1 # s5 = n-1
    mv   a0,t2
    call fib
    mv   s5, a0
    
    #calc fib(n-2)
    addi t3, s0, -2
    mv   a0, t3
    call fib
    mv   s6, a0
    
    #store cache[n] = fib(n-1) + fib (n-2)
    add  t4, s5, s6
    sw   t4, 0(s3)
    mv   a0, t4
    j    fib_ret
    

base_case_0:
    #basecase
    la   t0, cache
    li   t1, 0
    sw   t1, 0(t0)
    
    li   a0, 0
    j    fib_ret

base_case_1:

    la   t0, cache
    li   t1, 1
    sw   t1, 4(t0)
    
    li   a0, 1
    j    fib_ret
    
    
cache_hit:
    # if in cache return the value
    mv   a0, s4
    j    fib_ret
    
fib_ret:
    # EPILOGUE
    lw   s6, 0(sp)
    lw   s5, 4(sp)
    lw   s4, 8(sp)
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret