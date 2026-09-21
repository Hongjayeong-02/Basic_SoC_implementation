## Set Simulation

touch cds.lib hdl.var
mkdir -p work.lib

echo "define work_lib ./work.lib" > ./cds.lib
echo "define WORK work_lib" > ./hdl.var

## Compile HDL Sources
xmvlog -MESS -linedebug ./1_rtl/*.v ./2_tb/*.v

## Elaborate Compiled Sources
xmelab -MESS -access rwc tb_uart_tx

## Run simulation
xmsim -MESS tb_uart_tx -gui
