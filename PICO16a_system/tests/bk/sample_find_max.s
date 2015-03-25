#########################################
# Find the maximum value from an array
#########################################
@0x0
main:
	LDLI r1, array   # base address of an array
	LDLI r3, #0x0
	LDLI r4, #0x8    # size of an array
loop:
	LD r2, (r1)
	SUB r2, r3
	BMI r2, skip
	ADD r3, r2
skip:
	ADDI r1, #1
	SUBI r4, #1
	BNEZ r4, loop
	ST (r1), r3
finish:
	BEQZ r4, finish

@0x20
array:
	.half 0x5, 0x8, 0xc001, 0xa, 0x1020, 0x0, 0x22, 0x0FFF
