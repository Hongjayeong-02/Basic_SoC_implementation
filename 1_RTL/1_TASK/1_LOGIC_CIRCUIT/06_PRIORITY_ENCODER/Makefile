clean:
	rm -rf cds.lib hdl.var *.lib waves.shm *.log *.key *.dsn *.trn *.vcd*
	rm -rf *.simvision .symbol* xcelium.d work.lib

set: 
	touch cds.lib  hdl.var
	mkdir work.lib
	echo "define work_lib ./work.lib" >> ./cds.lib
	echo "define WORK work_lib" >> ./hdl.var

compile:
	xmvlog -MESS -linedebug ./priority_encoder_8.v
	xmvlog -MESS -linedebug ./priority_encoder.v
	xmvlog -MESS -linedebug ./tb_priority_encoder.v

elab: 
	xmelab -MESS -access rwc tb_priority_encoder

sim: 
	xmsim -gui -MESS tb_priority_encoder

all: clean set compile elab sim

