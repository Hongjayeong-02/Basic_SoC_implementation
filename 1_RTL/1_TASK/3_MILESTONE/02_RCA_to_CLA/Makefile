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


elab_tx:  
	xmelab -MESS -access rwc tb_uart_tx_9600


elab_rx:
	xmelab -MESS -access rwc tb_uart_rx_9600


elab_baud:
	xmelab -MESS -access rwc tb_baud_gen


elab_top:
	xmelab -MESS -access rwc tb_top_uart_calculator_9600

sim_tx: 
	xmsim -gui -MESS tb_uart_tx_9600

sim_rx: 
	xmsim -gui -MESS tb_uart_rx_9600

sim_baud:
	xmsim -gui -MESS tb_baud_gen

sim_top:
	xmsim -gui -MESS tb_top_uart_calculator_9600

all: clean set compile 
