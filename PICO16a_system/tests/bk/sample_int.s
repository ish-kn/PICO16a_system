#######################################
# sample interrupt
#######################################

	
	
#######################################
# main routine
	
@0x0
main:
	EINT
	LDLI	r6, #0
	LDLI	r3, lcdadr
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
	
	

#######################################
# interrupt routine
	
@0x180
interrupt:
	DINT # $B3d$j9~$_6X;_(B
	LDLI r0, segadr
	LD r0, (r0)
	LDLI r6, #4
	LDLI r2, #0
	LDLI r3, #0
segld:
	OR r3, r2
	BEQZ r6, addition
	LD r2, (r0)
	SUBI r0, #1
	SUBI r6, #1
	SL r3, r3
	SL r3, r3
	SL r3, r3
	SL r3, r3
	JMP segld
addition:
	ADDI r3, #1 # 7$B%;%0%a%s%H%G%#%9%W%l%$$NCM(B+1
	ADDI r0, #1
	LDLI r6, #4
segst:
	BEQZ r6, return
	ST (r0), r3
	ADDI r0, #1
	SUBI r6, #1
	SR r3, r3
	SR r3, r3
	SR r3, r3
	SR r3, r3
	JMP segst

return:
	#$B3d$j9~$_MW5a$r2<$2$k(B
	LDLI r0, intadr
	LD r0, (r0)
	ST (r0), r6
	
	RFI # $B%a%$%s%k!<%A%s$KLa$k(B
	
@0x40
segadr:	
	.half 0x800b
lcdadr:
	.half 0x8040
intadr:
	.half 0x800c
initdata:
	.half 0x0020
@0x50
data:
	.half 0x0048, 0x0065, 0x006c, 0x006c, 0x006f, 0x0020, 0x0057, 0x006f
	.half 0x0072, 0x006c, 0x0064, 0x0021, 0x0020, 0x0020, 0x0020, 0x0020
	.half 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020
	.half 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020, 0x0020
