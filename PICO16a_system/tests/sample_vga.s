#########################################
# VGA sample
#########################################
@0x00
main:
	LDLI    r3, vgaptr
	LD      r3, (r3)
	LDLI    r2, #0x10
	LDLI    r1, data
display:
	LD      r4, (r1)
	ST      (r3), r4
	ADDI    r1, #1
	ADDI    r3, #1
	SUBI    r2, #1
	BNEZ    r2, display
end:
	JMP     end
	
@0x50
data:
	.half 0x0048, 0x0065, 0x006c, 0x006c, 0x006f, 0x0020, 0x0057, 0x006f
	.half 0x0072, 0x006c, 0x0064, 0x0021, 0x0020, 0x0020, 0x0020, 0x0020

vgaptr:
	.half 0xa000
	
