## stop watch (VGA) ##

# main routine        
@0x0
main:
        LDLI r6, Stcp
        LD   r6, (r6)

        # for initialize VGA
        LDLI r3, InitData
        LD   r3, (r3)
        LDLI r0, vgaptr
        LD   r0, (r0)
        LDLI r2, #0xa     # 10 loop        
vgaup:  LDLI r5, #9       # 9 loop 
initvga:    # initialize VGA
        ST   (r0), r3
        ADDI r0, #1
        SUBI r5, #1
        BNEZ r5, initvga
        ADDI r0, #0x77
        SUBI r2, #1
        BNEZ r2, vgaup
        
        # for initialize 7-seg LED
        LDLI r2, #0
        LDLI r5, #4
        LDLI r0, SegAdr
        LD   r0, (r0)
initled:    # initialize LED
        ST   (r0), r2
        SUBI r5, #1
        BNEZ r5, initled 

inittimer:   # initialize timer  
        LDHI r5, 0x80 
	    ORI  r5, 0x02 
	    LDLI r1, 0x06 
	    ST   (r5), r1
        # set 0x004c4b40 (0.1sec)
        LDLI r2, data
	    LD   r3, (r2)
	    SUBI r5, 0x01
	    ST   (r5), r3
	    ADDI r2, 0x01
	    LD   r3, (r2)
	    SUBI r5, 0x01
	    ST   (r5), r3        
	    
        # initialize variables
        LDLI r5, count
        LDLI r1, #0
        LDLI r0, #4     # 4 loop
cntloop:    # initialize count
        ST   (r5), r1   # count[i] <= 0
        ADDI r5, #1
        SUBI r0, #1
        BNEZ r0, cntloop
        ADDI r1, #1
        ST   (r5), r1   # split <= 1
        
        JAL  runtimer

        EINT
        JMP  -1         # wait loop

# subroutines
######################
incsplit:
        LDLI r4, split
        LD   r4, (r4)

        LDLI r5, #9
        SUB  r5, r4
        BEQZ r5, reset
        ADDI r4, #1
        JMP  jr
reset:  LDLI r4, #0
jr:     LDLI r5, split
        ST   (r5), r4
        JR   r7
######################        
runtimer:
        # load initial value (0x004c4b40, 0.1sec)
        LDHI r5, 0x80
	    ORI  r5, 0x02
	    LDLI r3, 0x04
	    ST   (r5), r3
        
        # reboot timer
	    LDLI r1, 0x01
	    ST   (r5), r1
        
        JR   r7

######################
printsplit:
        LDLI r5, vgaptr10
        LD   r5, (r5)   
        LDLI r4, string # r4 <= adrs(string)
        LDLI r0, #9     # 9 loop
strloop:  # display const string      
        LD   r3, (r4)
        ST   (r5), r3   # disp
        ADDI r4, #1     # adrs++
        ADDI r5, #1
        SUBI r0, #1
        BNEZ r0, strloop

        LDLI r5, count
        LDLI r4, printpos
        LDLI r0, #5     # 5 loop
splitloop:  # display split time
        LD   r3, (r5)   # r3 <= count[i]
        ADDI r3, #0x30  # trans
        LD   r2, (r4)   # r2 <= printpos[i]
        ST   (r2), r3   # disp
        ADDI r4, #1     
        ADDI r5, #1     
        SUBI r0, #1
        BNEZ r0, splitloop
        
        JR   r7
######################                        
        
# timer interrupt routine        
@0x100
timer_int:
        DINT

        JMP inccount
        
run:    JAL runtimer

        # reset int_req1
        LDHI r5, 0x80
	    ORI  r5, 0x04
	    LD   r4, (r5)
	    ANDI r4, 0x00
	    ST   (r5), r4
        
        RFI

#### subroutine (inccount) ####
inccount:       
        LDLI r4, count
        LD   r0, (r4)   # r0 <= count[0]
        ADDI r4, #1     
        LD   r1, (r4)   # r1 <= count[1]
        ADDI r4, #1
        LD   r2, (r4)   # r2 <= count[2]
        ADDI r4, #1
        LD   r3, (r4)   # r3 <= count[3]

        # determine whether or not increment each
        LDLI r4, #9
        SUB  r4, r0
        BNEZ r4, add0
        LDLI r0, #0
        
        LDLI r4, #9
        SUB  r4, r1
        BNEZ r4, add1
        LDLI r1, #0

        LDLI r4, #5
        SUB  r4, r2
        BNEZ r4, add2
        LDLI r2, #0

        LDLI r4, #9
        SUB  r4, r3
        BNEZ r4, add3
        LDLI r3, #0

led:    LDLI r4, SegAdr
        LD   r4, (r4)
        ST  (r4), r3    # HEX3 <= r3
        SUBI r4, #1
        ST  (r4), r2    # HEX2 <= r2
        SUBI r4, #1
        ST  (r4), r1    # HEX1 <= r1
        SUBI r4, #1
        ST  (r4), r0    # HEX0 <= r0
        
        LDLI r4, count
        ST   (r4), r0   # count[0] <= r0
        ADDI r4, #1
        ST   (r4), r1   # count[1] <= r1
        ADDI r4, #1
        ST   (r4), r2   # count[2] <= r2
        ADDI r4, #1
        ST   (r4), r3   # count[3] <= r3

        JMP  run
        
add0:   ADDI r0, #1     # count[0]++
        JMP  led
add1:   ADDI r1, #1     # count[1]++
        JMP  led
add2:   ADDI r2, #1     # count[2]++
        JMP  led
add3:   ADDI r3, #1     # count[3]++   
        JMP  led
###################

# key interrupt routine
@0x180
key_int:
        DINT

        JMP  copysplit

print:  JAL  printsplit

        JAL  incsplit

        # reset int_req2
        LDLI r5, IntAdr
        LD   r5, (r5)
        LDLI r4, #0
        ST   (r5), r4

        RFI        

#### subroutine (copysplit) ####
copysplit:
        LDLI r4, vgaptr
        LD   r4, (r4)   # r4 <= 0xa000
        MV   r5, r4
        ADDI r5, #0x40
        ADDI r5, #0x40  # r5 <= 0xa080

        LDLI r2, #9     # 9 loop
vgaloop:LDLI r0, #9     # 9 loop
        
copyloop:   # line1 <= line2
        LD   r1, (r5)   # r1 <= line2[i]
        ST   (r4), r1   # line1[i] <= r1
        ADDI r4, #1
        ADDI r5, #1
        SUBI r0, #1
        BNEZ r0, copyloop

        ADDI r4, #0x77
        ADDI r5, #0x77
        SUBI r2, #1
        BNEZ r2, vgaloop
        
        JMP  print
######################
        
@0x60
data:
        .half 0x4b40 0x004c
string:
        .ascii "*S* * * *:* * *.* "
vgaptr:
        .half 0xa000
vgaptr10:
        .half 0xa480
printpos:
        .half 0xa488 0xa486 0xa485 0xa483 0xa481
count:
        .half 0x0 0x0 0x0 0x0
split:
        .half 0x1
SegAdr:
        .half 0x800b
IntAdr:
        .half 0x800c
Stcp:
        .half 0x01ff
InitData:
        .half 0x20
        