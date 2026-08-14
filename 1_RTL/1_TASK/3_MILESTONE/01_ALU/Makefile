clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd \
		.simvision *.diag .symbol* xcelium.d

set: 
	touch cds.lib  hdl.var
	mkdir work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var

compile:
	xmvlog -MESS -linedebug ./1_rtl/*.v ./2_tb/*.v

elab: 
	xmelab -MESS -access rwc tb_alu_8

sim: 
	xmsim -gui -MESS tb_alu_8

all: clean set compile elab sim

