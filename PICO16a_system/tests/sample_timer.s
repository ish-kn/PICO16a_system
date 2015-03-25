#########################################
# Sample timer
#########################################
@0x0
	DINT

	# �����ޤ˽���ͤ������Ԥ���
	# Timer control�쥸������0x06�򥹥ȥ�����
	# �����ޤν���ͤ�����ȥ����󥿤ؤν���ͤΥ��ɤ��ǽ�ˤ��롥
	LDHI r5, 0x80 
	ORI  r5, 0x02 
	LDLI r1, 0x06 
	ST   (r5), r1

	# �����󥿤ν���ͤ�0x019bfcc0(1sec)�����ꤹ�롥
	LDLI r2, data1
	LD   r3, (r2)
	SUBI r5, 0x01
	ST   (r5), r3
	ADDI r2, 0x01
	LD   r3, (r2)
	SUBI r5, 0x01
	ST   (r5), r3

	# ����ͤ��ɤ߹��߸塤�����ޤε�ư��
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r1, 0x01
	ST   (r5), r1

	# �����ޤθ��ߤ��ͤ�����������(0x72��0x73����)�ˤ����ͤ��Ǽ���롥
	LDLI r1, 0x09
	ST   (r5), r1
	LDHI r5, 0x80
	ORI  r5, 0x00
	LD   r1, (r5)
	ADDI r2, 0x01
	ST   (r2), r1
	ADDI r5, 0x01
	LD   r1, (r5)
	ADDI r2, 0x01
	ST   (r2), r1

	# ���ޥ�ɥ쥸������0x01�����ꤷ��Timer start/stop�ӥåȤΤߤ�1�ˤ��롥
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r1, 0x01
	ST   (r5), r1

	# �¹Ծ��֤�"1"�����ꤷ�������ߤ���Ĥ��롥
	# �ʹߤϳ����ߤ�ȯ������ޤ�̵�¥롼�פ��Ե����롥
	LDLI r1, runmode
	LDLI r2, 0x01
	ST   (r1), r2

	EINT

	LDLI r0, 0x00

	JMP -1

# �����޳����ߥ롼����
@0x100
	DINT

	# ���꤫��count���ͤ��ɤ߽Ф������󥯥���ȸ塤7-seg LED��ɽ����Ԥ���
	LDLI r4, count
	LD   r0, (r4)
	ADDI r0, 0x01
	ST   (r4), r0

	LDHI r4, 0x80
	ORI  r4, 0x08
	ST   (r4), r0

	# �����ޤ���γ����ߤ��׵�򲼤��롥
	LDHI r5, 0x80
	ORI  r5, 0x04
	LD   r3, (r5)
	ANDI r3, 0x00
	ST   (r5), r3
	
	RFI

# ���������ߥ롼����
@0x180
	DINT

	# �����ޤν���ͤ��ѹ��������ˡ����ä��󡤥����ޤ���ߤ����롥
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x00
	ST   (r5), r3

	# runmode�ȥ����ޤξ��֤��б�
	# "0" - ���������
	# "1" - 1�ä��Ȥ˥����ޤ���γ����ߤ�ȯ������褦������
	# "2" - 2�ä��Ȥ˥����ޤ���γ����ߤ�ȯ������褦������
	# runmode��"0"�ξ��ϡ�"1"���ѹ���
	# runmode��"1"�ξ��ϡ�"2"���ѹ���
	# runmode��"2"�ξ��ϡ�"0"���ѹ���
	LDLI r1, runmode
	LD   r2, (r1)
	BEQZ r2, runonesec
	SUBI r2, 0x01
	BEQZ r2, runtwosec

	LDLI r1, runmode
	LDLI r2, 0x00
	ST   (r1), r2

	JMP finish

runonesec:
	# �����ޤ˽���ͤ�񤭹��ࡥ
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r2, 0x02
	ST   (r5), r2

	SUBI r5, 0x01
	LDLI r1, data1
	LD   r2, (r1)
	ST   (r5), r2

	SUBI r5, 0x01
	ADDI r1, 0x01
	LD   r2, (r1)
	ST   (r5), r2

	LDLI r1, runmode
	LDLI r2, 0x01
	ST   (r1), r2

	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r2, 0x00
	ST   (r5), r2

	JMP load

runtwosec:
	# �����ޤ˽���ͤ�񤭹��ࡥ
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r2, 0x02
	ST   (r5), r2

	SUBI r5, 0x01
	LDLI r1, data2
	LD   r2, (r1)
	ST   (r5), r2

	SUBI r5, 0x01
	ADDI r1, 0x01
	LD   r2, (r1)
	ST   (r5), r2

	LDLI r1, runmode
	LDLI r2, 0x02
	ST   (r1), r2

	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r2, 0x00
	ST   (r5), r2

load:

	# �����ޤν���ͤ򥫥��󥿤��ɤ߹��ࡥ
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x04
	ST   (r5), r3

	# �����ޤ�¹Ծ��֤ذܹԤ����롥
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x01
	ST   (r5), r3

finish:

	# ���������ߤ�Ω�������롥
	LDHI r5, 0x80
	ORI  r5, 0x0c
	LDLI r3, 0x00
	ST  (r5), r3

	RFI

@0x70
data1:
	## ���ߥ�졼�����������֤���������ˤϡ�0x70, 0x71���ͤ��ѹ�
	# 1����
	.half 0xf080 0x02fa 0x0000 0x0000
	## �ѹ���
	#.half 0x0100 0x0000 0x0000 0x0000
data2:
	## ���ߥ�졼�����������֤���������ˤϡ�0x74, 0x75���ͤ��ѹ�
	# 2����
	.half 0xe100 0x05f5   0x0000 0x0000
	## �ѹ���
	#.half 0x0200 0x0000 0x0000 0x0000
runmode:
	.half 0x0
count:
	.half 0x0000
