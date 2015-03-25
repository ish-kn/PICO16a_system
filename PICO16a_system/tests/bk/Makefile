VERILOG=/home/course/comporg/bin/ncverilog
VERILOG_SOURCE=test_timer.v \
../rtl/PICO16a_system.v \
../rtl/util_register_1bit.v \
../rtl/util_register.v \
../rtl/util_genClk.v \
../rtl/memory.v \
../rtl/memory_lpm.v \
../rtl/pico16a.v \
../rtl/sevenseg_dec.v \
../rtl/adrs_dec_7seg.v \
../rtl/dev_cnt_7seg.v \
../rtl/dev_interface_7seg.v \
../rtl/dev_interface_LCD.v \
../rtl/dev_cnt_LCD.v \
../rtl/LCD_raw_controller.v \
../rtl/dpram8x32.v \
../rtl/testram.v \
../rtl/key_int.v \
../rtl/dev_cnt_key3int.v \
../rtl/timer.v \
../rtl/dev_cnt_timer.v \
/usr/local/quartus-12.0/quartus/eda/sim_lib/altera_mf.v
LANG = C
LC_ALL = C

VL_OPT=
VIEWER=/home/course/comporg/bin/simvision
PERL=perl /home/course/comporg/bin/pasm.pl

sim:    perl-sim simulation viewer

perl-sim:
	$(PERL) -v sample_timer.s

perl-fpga:
	$(PERL) -m sample_timer.s

simulation:
		rm -rf INCA_libs test_timer result_timer.txt
	$(VERILOG) $(VERILOG_SOURCE) $(VL_OPT) 

viewer:
	$(VIEWER) -input simvision.svcf


clean:
	rm -rf *~ INCA_libs test_timer result_timer.txt sample_timer.mem sample_timer.mif 
