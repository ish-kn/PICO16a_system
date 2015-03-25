#########################################
# Display number on the 7-seg LEDs
#########################################
@0x0
main:
    LDHI r2, #0x80
    ORI  r2, #0x00
    BMI  r2, hoge
    ADDI r2, #1
hoge:LDLI r4, #0x4
        
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

@0x20
data:
        .half 0x1234
	