clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd*
	rm -rf *.simvision .symbol* xcelium.d work.lib

set: 
	touch cds.lib  hdl.var
	mkdir -p work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var

compile:
	xmvlog -MESS -linedebug ../2_HALF_ADDER/half_adder.v
	xmvlog -MESS -linedebug ../3_FULL_ADDER/full_adder.v
	xmvlog -MESS -linedebug ../4_RIPPLE_CARRY_ADDER/ripple_carry_adder.v
	xmvlog -MESS -linedebug ./subtractor.v
	xmvlog -MESS -linedebug ./tb_subtractor.v

elab: 
	xmelab -MESS -access rwc tb_subtractor

sim: 
	xmsim -gui -MESS tb_subtractor

all: clean set compile elab sim

