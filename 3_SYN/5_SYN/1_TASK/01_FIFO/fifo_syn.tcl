# Library search path
set_db init_lib_search_path ../../../../3_SYN/1_LIB

# # RTL search path
set_db init_hdl_search_path ../../../../1_RTL/1_TASK/2_SYSTEM_DISIGN/06_FIFO

# # Read standard cell library
read_libs slow_vdd1v0_basicCells.lib

# # Read RTL
read_hdl fifo.v

# # Elaborate design
elaborate fifo

# # Read timing constraints
read_sdc fifo.sdc

# # Synthesis effort
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# # Synthesis
syn_generic
syn_map
syn_opt

# # Reports
report_timing > reports/fifo_timing.rpt
report_power  > reports/fifo_power.rpt
report_area   > reports/fifo_area.rpt
report_qor    > reports/fifo_qor.rpt

# # Output netlist
write_hdl > outputs/fifo_netlist.v

# # Output SDC
write_sdc > outputs/fifo_syn.sdc

# # Keep GUI open
gui_raise
