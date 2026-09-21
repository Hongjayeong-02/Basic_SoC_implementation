TOP = tb_uart_loopback

clean:
	rm -rf xcelium.d
	rm -rf work.lib
	rm -rf waves.shm
	rm -f cds.lib
	rm -f hdl.var
	rm -f *.log
	rm -f *.key
	rm -f *.history
	rm -f *.vcd

set:
	touch cds.lib hdl.var
	mkdir -p work.lib
	echo "define work_lib ./work.lib" > ./cds.lib
	echo "define WORK work_lib" > ./hdl.var

compile:
	xmvlog -MESS -linedebug ./1_rtl/*.v ./2_tb/*.v

elab:
	xmelab -MESS -access rwc $(TOP)

sim: 
	xmsim -MESS $(TOP) -gui

all: set compile elab sim
