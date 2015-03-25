#########################################
# Display number on the 7-seg LEDs
# And check overflow
#########################################
@0x0
main:
    LDHI r2, #0x80  
    ORI  r2, #0x01  # r2 <= 0x8001 (negative number)
    ADD  r2, r2     
    BPL  r2, ERROR  # if (r2 >= 0) goto ERROR (overflow)

set:
    LDLI r4, #0x4
	LDHI r3, #0x80
    ORI  r3, #0x8

loop:		
    ST  (r3), r2
	ADDI r3, #1
	
	SR   r2, r2
	SR   r2, r2
	SR   r2, r2
	SR   r2, r2

	SUBI r4, #1
	BNEZ r4, loop

finish:
        BEQZ r4, finish

ERROR:  LDHI r2, #0xff
        ORI  r2, #0xff
        JMP  set