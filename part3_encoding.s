.data 
inst_1:     .word 0x403100B3 #R-typy
inst_2:     .word 0x0FF36293 #I-type
inst_3:     .word 0x00742423 #S-Type
inst_4:     .word 0x00208863 #B-Type
inst_5:     .word 0x123454B7 #U-Type
inst_6:     .word 0x1000056F #J-Type
instrMsg:   .string "Instruction: "
opcodeMsg:  .string "opcode: "
rdMsg:      .string "rd: "
rs1Msg:     .string "rs1: "
func3Msg:   .string "func3: "

.text
.globl main
main:
    #opcodes for skip
    li s0, 0x23 #opcode of S-Type
    li s1, 0x63 #opcode of B-Type
    li s2, 0x37 #opcode of U-Type (lui)
    li s3, 0x17 #opcode of U-Type (auipc)
    li s4, 0x6F #opcode of J-Type 
    
    #inst_1
    la a0, inst_1
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #inst_2
    la a0, inst_2
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #inst_3
    la a0, inst_3
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #inst_4
    la a0, inst_4
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #inst_5
    la a0, inst_5
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #inst_6
    la a0, inst_6
    call decode_instr
    
    #newline
    li a1 '\n'
    li a0 11
    ecall
    
    #exit
    li a0, 10
    ecall
    
    
#decode_instr(a0=instruction)
decode_instr:
    
    lw t0, 0(a0)
    
    print_instr:    

        #Print instruction
        la a1, instrMsg
        li a0, 4
        ecall
        mv a1, t0
        li a0, 34
        ecall
        
        #newline
        li a1 '\n'
        li a0 11
        ecall
        
    extract_opcode:    
    
        #extract opcode
        andi t1, t0, 0x7F  #t1 = opcode
        la a1, opcodeMsg
        
        #print opcode
        li a0, 4
        ecall
        mv a1, t1
        li a0, 34
        ecall
        
        #newline
        li a1 '\n'
        li a0 11
        ecall
        
    extract_rd:    
    
        #skip for intructions dont have rd
        beq t1, s0, extract_rs1
        beq t1, s1, extract_rs1
        
        #extract rd
        srli t2, t0, 7
        andi t3, t2, 0x1F
        
        #print rd
        la a1, rdMsg
        li a0, 4
        ecall
        mv a1, t3
        li a0, 34
        ecall
        
        #newline
        li a1 '\n'
        li a0 11
        ecall
        
    extract_rs1:
        
        #skip for intructions dont have rs1
        beq t1, s2, extract_func3
        beq t1, s3, extract_func3
        beq t1, s4, extract_func3
        
        #extract rs1
        srli t2, t0, 15
        andi t3, t2, 0x1F
        
        #print rs1
        la a1, rs1Msg
        li a0, 4
        ecall
        mv a1, t3
        li a0, 34
        ecall
        
        #newline
        li a1 '\n'
        li a0 11
        ecall
        
    extract_func3:    
    
        #skip for intructions dont have func3
        beq t1, s2, end_decode
        beq t1, s3, end_decode
        beq t1, s4, end_decode
        
        #extract func3
        srli t2, t0, 12
        andi t3, t2, 0x7
        
        #print func3
        la a1, func3Msg
        li a0, 4
        ecall
        mv a1, t3
        li a0, 34
        ecall

        #newline
        li a1 '\n'
        li a0 11
        ecall
        

        
end_decode:
    ret
    