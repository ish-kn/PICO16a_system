@0x0
main:
        # init #
        LDLI r6, stackinit
        LD   r6, (r6)
        LDLI r0, result
        LDLI r1, #0x20
        LDLI r2, #0x20
        LDLI r3, #0x20
        LDLI r4, #0x20
        LDLI r5, #0x20

        # prepare JAL #
        SUBI r6, #1
        ST   (r6), r5
        SUBI r6, #1
        ST   (r6), r4
        SUBI r6, #1
        ST   (r6), r3
        SUBI r6, #1
        ST   (r6), r2
        SUBI r6, #1
        ST   (r6), r1
        SUBI r6, #1
        ST   (r6), r0

        JAL hextodec

        # reg <= stack
        LD   r0, (r6)
        ADDI r6, #1
        LD   r1, (r6)        
        ADDI r6, #1
        LD   r2, (r6)        
        ADDI r6, #1
        LD   r3, (r6)        
        ADDI r6, #1
        LD   r4, (r6)        
        ADDI r6, #1
        LD   r5, (r6)        
        ADDI r6, #1

        # store reg to mem
        ST   (r0), r1
        ADDI r0, #1
        ST   (r0), r2        
        ADDI r0, #1
        ST   (r0), r3        
        ADDI r0, #1
        ST   (r0), r4        
        ADDI r0, #1
        ST   (r0), r5        
        ADDI r0, #1        
        
        JMP -1

hextodec:
        LDLI r0, data
        LD   r0, (r0)
        LDLI r4, mask
        LDLI r5, #0     # l_count <= 0

loop:   
        LDLI r1, #0     # count <= 0
        LD   r2, (r4)   # r2 <= mask
tmp:    MV   r3, r0     # tmp <= data
        SUB  r0, r2     # data <= data - mask
        BMI  r0, tmp2   # if (r0 < 0) goto tmp2
        ADDI r1, #1     # count++ 
        JMP  tmp
tmp2:   MV   r0, r3     # data <= tmp
        # display count(r1) to 7-seg LED                 
        LDHI r3, #0x80
        ORI  r3, #0x0b
        SUB  r3, r5     # r3 <= 0x800b - l_count
        ST   (r3), r1   # Mem[r3] <= count

        ADDI r4, #1     # mask++
        ADDI r5, #1     # l_count++
        LDLI r1, #3
        SUB  r1, r5     # r1 <= 3 - l_count
        BNEZ r1, loop   # if (l_count != 3) goto loop

        SUBI r3, #1     # r3 <= 0x8008
        ST   (r3), r0   # HEX0
        
        JR   r7
        
@0x70        
data:
        .half 0x270f
mask:
        .half 1000 100 10

stackinit:
        .half 0x01ff

result:
        .half 0x0 0x0 0x0 0x0 0x0
