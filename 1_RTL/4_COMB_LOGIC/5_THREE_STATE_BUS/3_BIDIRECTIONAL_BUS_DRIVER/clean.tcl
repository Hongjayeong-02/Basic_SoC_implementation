## Set Simulation

touch cds.lib hdl.var
mkdir work.lib
echo "define work_lib ./work.lib" >> ./cds.lib
echo "define WORK work_lib" >> ./hdl.var

# Compile HDL Sources
xmvlog -MESS -linedebug ./*v

## Elaborate compiled sources
xmelab -MESS -access rwc tb_comparator

## run simulation in CLI mode
xmsim -MESS tb_comparator -gui
