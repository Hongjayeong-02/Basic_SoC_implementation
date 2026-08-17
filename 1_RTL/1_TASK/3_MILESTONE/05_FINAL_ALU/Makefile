clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd \
		.simvision *.diag .symbol* xcelium.d work.lib


set: 
	touch cds.lib  hdl.var
	mkdir work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var


compile:
	xmvlog -MESS -linedebug ./1_rtl/*.v ./2_tb/*.v


elab_mul: 
	xmelab -MESS -access rwc tb_mul_8


sim_mul:
	xmsim -gui -MESS tb_mul_8


elab_divu:
	xmelab -MESS -access rwc tb_divu_8


sim_divu:
	xmsim -gui -MESS tb_divu_8


elab_divs:
	xmelab -MESS -access rwc tb_divs_8


sim_divs:
	xmsim -gui -MESS tb_divs_8


elab_alu:
	xmelab -MESS -access rwc tb_logit_alu


sim_alu:
	xmsim -gui -MESS tb_logit_alu


all: clean set compile elab_alu sim_alu

