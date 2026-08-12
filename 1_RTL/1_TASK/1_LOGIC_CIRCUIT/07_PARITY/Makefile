clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd*
	rm -rf *.simvision .symbol* xcelium.d work.lib

set: 
	touch cds.lib  hdl.var
	mkdir work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var

compile:
	xmvlog -MESS -linedebug ./parity.v
	xmvlog -MESS -linedebug ./tb_parity.v

elab: 
	xmelab -MESS -access rwc tb_parity

sim: 
	xmsim -gui -MESS tb_parity

all: clean set compile elab sim

