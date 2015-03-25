###############################################################################
#LCD sample     
###############################################################################
@0x00
	LDLI	r6, #0
	LDLI	r3, lcdptr
	LD	r3, (r3)
	LDLI	r2, #0x20
	LDLI	r1, data
display:
	LD	r4, (r1)
	ST	(r3), r4
	ADDI	r1, #1
	ADDI	r3, #1
	SUBI	r2, #1
	BNEZ	r2, display
end:
	JMP	end


@0x50
data:
#	.half 0x0073, 0x0031, 0x0031, 0x0039, 0x0030, 0x0032, 0x0030, 0x0035
#	.half 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020
#	.half 0x004b, 0x0065, 0x006e, 0x0074, 0x0061, 0x0020, 0x0049, 0x0073
#	.half 0x0068, 0x0069, 0x006b, 0x0061, 0x0077, 0x0061, 0x0020, 0x0020
        .ascii " U n i v .   o f   A i z u      "
        .ascii " c o m p o r g                  "
lcdptr:
	.half 0x8040