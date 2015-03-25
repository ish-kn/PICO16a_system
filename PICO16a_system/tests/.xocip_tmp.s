## stop watch ##

# main routine        
@0x0
main:
        LDLI r6, Stcp
        LD   r6, (r6)

        # for initilize lcd
        LDLI r2, #0
	    LDLI r3, InitData
	    LD r3, (r3)
	    LDLI r5, #0x20
	    LDLI r0, LcdAdr
	    LD r0, (r0)

initlcd:    # initialize LCD
	    ST (r0), r3
	    ADDI r0, #1
	    SUBI r5, #1
	    BNEZ r5, initlcd

        # for initialize 7-seg LED
        LDLI r2, #0
        LDLI r5, #4
        LDLI r0, SegAdr
        LD   r0, (r0)

initled:    # initialize LED
        ST   (r0), r2
        SUBI r5, #1
        BNEZ r5, initled 

initimer:   # initialize timer  
        LDHI r5, 0x80 
	    ORI  r5, 0x02 
	    LDLI r1, 0x06 
	    ST   (r5), r1

        JAL  runtimer

        LDLI r0, #1     # split        

        EINT
        JMP  -1
        

# subroutines
incsplit:
        # for experiment
        LDLI r2,SegAdr
        LD   r2, (r2)
        ST   (r2), r0

        LDLI r1, #9
        SUB  r1, r0
        BEQZ r1, reset
        ADDI r0, #1
        JR   r7
reset:  LDLI r0, #0
        JR   r7

runtimer:
        # set 0x004c4b40 (0.1sec)
	    LDLI r2, data
	    LD   r3, (r2)
	    SUBI r5, 0x01
	    ST   (r5), r3
	    ADDI r2, 0x01
	    LD   r3, (r2)
	    SUBI r5, 0x01

        # run timer
        LDHI r5, 0x80
	    ORI  r5, 0x02
	    LDLI r1, 0x01
	    ST   (r5), r1
        
        JR r7
        
        
# timer interrupt routine        
@0x100
timer_int:
        DINT

        JAL incsplit

        # reset int_req1
        LDHI r5, 0x80
	    ORI  r5, 0x04
	    LD   r3, (r5)
	    ANDI r3, 0x00
	    ST   (r5), r3
        
        RFI

# key interrupt routine        
@0x180
key_int:
        DINT

        JAL incsplit

        # reset int_req2
        LDLI r2, IntAdr
        LD   r2, (r2)
        LDLI r1, #0
        ST   (r2), r1

        RFI
        
@0x70
data:
        .half 0x4b40 0x004c
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
        