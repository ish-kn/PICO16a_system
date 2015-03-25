## slot machine ##

# main routine        
@0x0
main:
        LDLI r6, Stcp
        LD   r6, (r6)

        JAL  initlcd

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
        # set 0x002faf08 (1/16 sec)
        LDLI r2, data
	    LD   r3, (r2)
	    SUBI r5, 0x01
	    ST   (r5), r3
	    ADDI r2, 0x01
	    LD   r3, (r2)
	    SUBI r5, 0x01
	    ST   (r5), r3        
	    
        # initialize status
        LDLI r5, status
        LDLI r4, #0x07
        ST   (r5), r4
        
        JAL  runtimer

        EINT
        JMP  -1         # wait loop

# subroutines
######################                
initlcd:        
        # for initilize lcd
        LDLI r2, #0
	    LDLI r3, InitData
	    LD r3, (r3)
	    LDLI r5, #0x20
	    LDLI r0, LcdAdr
	    LD r0, (r0)
loopsp: # initialize LCD
	    ST (r0), r3
	    ADDI r0, #1
	    SUBI r5, #1
	    BNEZ r5, loopsp

        JR   r7
######################        
runtimer:
        # load initial value (0x002faf08, 1/16sec)
        LDHI r5, 0x80
	    ORI  r5, 0x02
	    LDLI r3, 0x04
	    ST   (r5), r3
        
        # reboot timer
	    LDLI r1, 0x01
	    ST   (r5), r1
        
        JR   r7
######################        
statetransition:
        LDLI r5, status
        LD   r4, (r5)   # r4 <= status
        BNEZ r4, shift  # if (r4 != 0) goto shift
        LDLI r4, #0x07
        JMP  ret
shift:  SR   r4, r4     # r4 <= (r4 >> 1)
        
ret:    ST   (r5), r4   # status <= r4
        JR   r7
######################
lcddisplay:
        LDLI r5, status
        LD   r5, (r5)   # r5 <= status
        BNEZ r5, init   # if (status != 0) goto init
        
        LDHI r4, #0x80
        ORI  r4, #0x08
        LD   r0, (r4)   # r0 <= HEX[0]
        ADDI r4, #1     
        LD   r1, (r4)   # r1 <= HEX[1]
        
        SUB  r0, r1     
        BNEZ r0, init   # if (r0 != r1) goto init
        
        ADDI r4, #1
        LD   r2, (r4)   # r2 <= HEX[2]

        SUB  r1, r2
        BNEZ r1, init   # if (r1 != r2) goto init
        
        LDLI r5, LcdAdr
        LD   r5, (r5)
        LDLI r4, msg
        LDLI r0, #5     # 5 loop
loopmsg:LD   r3, (r4)   
        ST   (r5), r3   # Mem[LcdAdr+i] <= msg[i]
        ADDI r5, #1
        ADDI r4, #1
        SUBI r0, #1
        BNEZ r0, loopmsg
        JMP  end

init:   SUBI r6, #1
        ST   (r6), r7
        JAL initlcd
        LD   r7, (r6)
        ADDI r6, #1
        
end:    JR   r7
######################        
stopled:
        LDLI r5, status
        LD   r5, (r5)   # r5 <= status
        LDHI r4, #0x80
        ORI  r4, #0x08
        LDLI r2, #0x01        
        LDLI r3, #3     # 3 loop 
        
loopled:LD   r0, (r4)   # r0 <= HEX[i]
        MV   r1, r2     
        AND  r1, r5
        BEQZ r1, next

        ADDI r0, #1     # r0++
        LDLI r1, #0x10
        SUB  r1, r0
        BNEZ r1, led
        LDLI r0, #0     # r0 <= 0
        
led:    ST  (r4), r0    # HEX[i] <= r0

next:   ADDI r4, #1     
        SUBI r3, #1
        SL   r2, r2
        BNEZ r3, loopled
        
        JR   r7
######################        
        
# timer interrupt routine        
@0x100
timer_int:
        DINT

        JAL stopled
        
        JAL runtimer

        # reset int_req1
        LDHI r5, 0x80
	    ORI  r5, 0x04
	    LD   r4, (r5)
	    ANDI r4, 0x00
	    ST   (r5), r4
        
        RFI

# key interrupt routine
@0x180
key_int:
        DINT

        JAL  statetransition
        
        JAL  lcddisplay

        # reset int_req2
        LDLI r5, IntAdr
        LD   r5, (r5)
        LDLI r4, #0
        ST   (r5), r4

        RFI        
        
@0x70
data:
        .half 0xaf08 0x002f
        # for debug (0.5 sec)
#        .half 0x7840 0x017d
status:
        .half 0x0000
msg:
        .half 0x00b5 0x00b5 0x00b1 0x00c0 0x00d8
SegAdr:
        .half 0x800b
LcdAdr:
        .half 0x8040
IntAdr:
        .half 0x800c
Stcp:
        .half 0x01ff
InitData:
        .half 0x20
        