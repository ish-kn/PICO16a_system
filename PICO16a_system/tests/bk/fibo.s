@0x0
main:
        LDLI r6, stackinit
        LD   r6, (r6)
        LDLI r0, num
        LD   r0, (r0)   # r0 <= n
        LDLI r5, #0

        JAL fibonacci   # call fibo(n)

        LDLI r3, result
        ST   (r3), r5   # Mem[result] <= fibo(n)
        
        JMP -1
        
fibonacci:
        MV   r1, r0
        SUBI r1, #3
        BPL  r1, ret2
ret1:
        SUBI r0, #1
        MV   r5, r0
        JR   r7
ret2:
        SUBI r0, #1
        
        SUBI r6, #1
        ST   (r6), r7
        SUBI r6, #1
        ST   (r6), r0
        JAL  fibonacci  # fibo(n-1)
        LD   r0, (r6)
        ADDI r6, #1
        LD   r7, (r6)
        ADDI r6, #1
        
        MV   r4, r5     # r4 <= fibo(n-1)
        SUBI r0 #1

        SUBI r6, #1
        ST   (r6), r7
        SUBI r6, #1
        ST   (r6), r4
        SUBI r6, #1
        ST   (r6), r0
        JAL  fibonacci  # fibo(n-2)
        LD   r0, (r6)
        ADDI r6, #1
        LD   r4, (r6)
        ADDI r6, #1         
        LD   r7, (r6)
        ADDI r6, #1 
        
        ADD  r5, r4     # r5 <= fibo(n-2) + fibo(n-1)
        JR   r7
        
@0x30
num:
        .half 0x7
stackinit:
        .half 0x01ff
result:
        .half 0x0