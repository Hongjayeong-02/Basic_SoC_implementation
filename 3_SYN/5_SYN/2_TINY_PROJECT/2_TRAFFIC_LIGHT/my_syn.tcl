set_db init_lib_search_path /home/hah006/Basic_SoC_implementation/3_SYN/1_LIB 
set_db init_hdl_search_path /home/hah006/Basic_SoC_implementation/1_RTL/2_TINY_PROJECT/2_TRAFFIC_LIGHT

read_libs slow_vdd1v0_basicCells.lib

read_hdl traffic_light.v

elaborate

read_sdc /home/hah006/Basic_SoC_implementation/3_SYN/2_CONSTRAINTS/sample.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium


syn_generic
syn_map
syn_opt

report_timing > reports/report_timing_rpt
report_power > reports/report_power.rpt
report_area > reports/report_area.rpt
report_qor > reports/report_qor.rpt

write_hdl > outputs/traffic_light_netlist.v
write_sdc > outputs/traffic_ligh_final.sdc
