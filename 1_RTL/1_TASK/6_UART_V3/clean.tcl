## Set Simulation

touch cds.lib hdl.var
mkdir work.lib
echo "define work_lib ./work.lib" >> ./cds.lib
echo "define WORK work_lib" >> ./hdl.var

# Compile HDL Sources
xmvlog -MESS -linedebug ./1_rtl_*.v ./2_tb/*.v

## Elaborate compiled sources
xmelab -MESS -access rwc tb_uart_v3_final

## run simulation in CLI mode
xmsim -MESS tb_uart_v3_finalp -gui
