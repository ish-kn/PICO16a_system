#########################################
# Sample timer
#########################################
@0x0
	DINT

	# タイマに初期値の設定を行う．
	# Timer controlレジスタに0x06をストアし，
	# タイマの初期値の設定とカウンタへの初期値のロードを可能にする．
	LDHI r5, 0x80 
	ORI  r5, 0x02 
	LDLI r1, 0x06 
	ST   (r5), r1

	# カウンタの初期値に0x019bfcc0(1sec)を設定する．
	LDLI r2, data1
	LD   r3, (r2)
	SUBI r5, 0x01
	ST   (r5), r3
	ADDI r2, 0x01
	LD   r3, (r2)
	SUBI r5, 0x01
	ST   (r5), r3

	# 初期値の読み込み後，タイマの起動．
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r1, 0x01
	ST   (r5), r1

	# タイマの現在の値を習得し，メモリ(0x72，0x73番地)にその値を格納する．
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

	# コマンドレジスタに0x01を設定し，Timer start/stopビットのみを1にする．
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r1, 0x01
	ST   (r5), r1

	# 実行状態を"1"に設定し，割り込みを許可する．
	# 以降は割り込みが発生するまで無限ループで待機する．
	LDLI r1, runmode
	LDLI r2, 0x01
	ST   (r1), r2

	EINT

	LDLI r0, 0x00

	JMP -1

# タイマ割り込みルーチン
@0x100
	DINT

	# メモリからcountの値を読み出し，インクリメント後，7-seg LEDに表示を行う．
	LDLI r4, count
	LD   r0, (r4)
	ADDI r0, 0x01
	ST   (r4), r0

	LDHI r4, 0x80
	ORI  r4, 0x08
	ST   (r4), r0

	# タイマからの割り込みを要求を下げる．
	LDHI r5, 0x80
	ORI  r5, 0x04
	LD   r3, (r5)
	ANDI r3, 0x00
	ST   (r5), r3
	
	RFI

# キー割り込みルーチン
@0x180
	DINT

	# タイマの初期値を変更する前に，いったん，タイマを停止させる．
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x00
	ST   (r5), r3

	# runmodeとタイマの状態の対応
	# "0" - タイマ停止
	# "1" - 1秒ごとにタイマからの割り込みが発生するように設定
	# "2" - 2秒ごとにタイマからの割り込みが発生するように設定
	# runmodeが"0"の場合は，"1"に変更．
	# runmodeが"1"の場合は，"2"に変更．
	# runmodeが"2"の場合は，"0"に変更．
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
	# タイマに初期値を書き込む．
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
	# タイマに初期値を書き込む．
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

	# タイマの初期値をカウンタに読み込む．
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x04
	ST   (r5), r3

	# タイマを実行状態へ移行させる．
	LDHI r5, 0x80
	ORI  r5, 0x02
	LDLI r3, 0x01
	ST   (r5), r3

finish:

	# キー割り込みを立ち下げる．
	LDHI r5, 0x80
	ORI  r5, 0x0c
	LDLI r3, 0x00
	ST  (r5), r3

	RFI

@0x70
data1:
	## シミュレーション時、時間がかかる場合には、0x70, 0x71の値を変更
	# 1秒用
	.half 0xf080 0x02fa 0x0000 0x0000
	## 変更例
	#.half 0x0100 0x0000 0x0000 0x0000
data2:
	## シミュレーション時、時間がかかる場合には、0x74, 0x75の値を変更
	# 2秒用
	.half 0xe100 0x05f5   0x0000 0x0000
	## 変更例
	#.half 0x0200 0x0000 0x0000 0x0000
runmode:
	.half 0x0
count:
	.half 0x0000
