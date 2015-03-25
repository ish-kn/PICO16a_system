#######################################
# interrupt   
#######################################

	
#######################################
# メインルーチン

@0x0
main:
	# 割り込み許可
	EINT
	# LCDの初期化のための準備
	LDLI r2, #0
	LDLI r3, InitData
	LD r3, (r3)
	LDLI r5, #0x20
	LDLI r0, LcdAdr
	LD r0, (r0)

initlcd:#LCDの初期化
	ST (r0), r3
	ADDI r0, #1
	SUBI r5, #1
	BNEZ r5, initlcd

mainloop:#メインルーチンの処理
	LDLI r0, CntNum
	LD r0, (r0)
decrease:#値をデクリメント
	BEQZ r0, load
	SUBI r0, #1
	JMP decrease
load: # 7セグメントから値をLDするための準備
	LDLI r1, SegAdr #r1 = 0x61
	LDLI r5, #4
	LD r1, (r1) # r1 = 0x800b
loadloop:# 4つの7セグメントからLDした値(各4bit)を1つ(16bit)にまとめる
	OR r3, r2
	BEQZ r5, store
	LD r2, (r1) # r2 = value of HEX4
	SUBI r1, #1 # r1 = 0x800a
	SUBI r5, #1
	SL r3, r3
	SL r3, r3
	SL r3, r3
	SL r3, r3
	JMP loadloop
store:	#7セグメントからロードした値をインクリメントして
	#7セグメントにストアする準備
	ADDI r3, #1
	ADDI r1, #1
	LDLI r5, #4
storeloop: # 7セグメントディスプレイに値をストア
	BEQZ r5, mainloop
	ST (r1), r3
	ADDI r1, #1
	SUBI r5, #1
	SR r3, r3
	SR r3, r3
	SR r3, r3
	SR r3, r3
	JMP storeloop

## メインルーチンここまで
#########################################

	
#########################################
## 割り込みサブルーチン

intsubroutine:
	    # 演習資料5、図5の点線で囲まれている処理を記述してください
        # store registers to stack (use r0, r1, r2, r3 in subroutine)
        LDLI r6, Stcp
        LD   r6, (r6)

        SUBI r6, #1         
        ST   (r6), r3
        SUBI r6, #1                 
        ST   (r6), r2        
        SUBI r6, #1        
        ST   (r6), r1
        SUBI r6, #1
        ST   (r6), r0

        LDHI r0, #0
        LDHI r1, #0
        LDHI r2, #0     # cnt <= 0
        LDLI r1, LcdAdr
        LD   r1, (r1)   # r1 <= 0x8040
loopConv:
        LDLI r0, SegAdr
        LD   r0, (r0)   # r0 <= 0x800b
        SUB  r0, r2     # r0 <= r0 - cnt
        LD   r0, (r0)   # load 7-seg value
        LDHI r3, #0
        ORI  r3, #0x9
        SUB  r3, r0
        BMI  r3, alph   # if (value > 9) goto alph
        ADDI r0, #0x30  # for LCD (number)
        JMP  storeLCD
alph:   ADDI r0, #0x37  # for LCD (alphabet)
storeLCD:
        ST   (r1), r0   # display to LCD
        ADDI r1, #1     # LCD adrs++
        ADDI r2, #1     # cnt++
        LDLI r0, #4
        SUB  r0, r2
        BNEZ r0, loopConv    # if (cnt < 4) goto loopConv
        
	    JMP rfi
	
## 割り込みサブルーチンここまで。
#########################################
	
	
#########################################
## 割り込みルーチン
@0x180
interrupt:
	    #割り込みを禁止する記述を追加してください
        DINT
        JMP intsubroutine # 割り込みサブルーチンへ
rfi:	
	    #割り込み要求を下げる記述を追加してください
        LDHI r0, #0
        LDLI r2, IntAdr
        LD   r2, (r2)   # r1 <= 0x800c
        ST   (r2), r0   # Mem[0x800c] <= 0
        # load registers from stack
        LD   r0, (r6)
        ADDI r6, #1
        LD   r1, (r6)
        ADDI r6, #1
        LD   r2, (r6)        
        ADDI r6, #1
        LD   r3, (r6)
        ADDI r6, #1        
	    #メインルーチンに戻る記述を追加してください
        RFI

## 割り込みルーチンここまで。
#########################################


#########################################
## データ
@0x60
CntNum:	
	.half 0x7fff
SegAdr:	
	.half 0x800b
LcdAdr:
	.half 0x8040
IntAdr:
	.half 0x800c
Stcp:
	.half 0x1ff
InitData:
	.half 0x20
