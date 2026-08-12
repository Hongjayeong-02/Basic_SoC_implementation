clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd \
		.simvision .symbol* xcelium.d

set: 
	touch cds.lib  hdl.var
	mkdir work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var

compile:
	xmvlog -MESS -linedebug ../2_HALF_ADDER/half_adder.v
	xmvlog -MESS -linedebug ./full_adder.v
	xmvlog -MESS -linedebug ./tb_full_adder.v

elab: 
	xmelab -MESS -access rwc tb_full_adder

sim: 
	xmsim -gui -MESS tb_full_adder

all: clean set compile elab sim

