set_db init_lib_search_path /home/hah006/Basic_SoC_implementation/3_SYN/1_LIB 
set_db init_hdl_search_path /home/hah006/Basic_SoC_implementation/1_RTL/4_COMB_LOGIC/1_MUX

read_libs /home/hah006/Basic_SoC_implementation/3_SYN/1_LIB/slow_vdd1v0_basicCells.lib

read_hdl /home/hah006/Basic_SoC_implementation/1_RTL/4_COMB_LOGIC/1_MUX/gpio_mux.v

elaborate

read_sdc /home/hah006/Basic_SoC_implementation/3_SYN/2_CONSTRAINTS/sample.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium


syn_generic
syn_map
syn_opt

report_timing > ./report/report_timing_rpt
report_power > ./report/report_power.rpt
report_area > ./report/report_area.rpt
report_qor > ./report/report_qor.rpt

write_hdl > ./outputs/gpio_mux_netlist.v
write_sdc > ./outputs/gpio_mux_final.sdc
