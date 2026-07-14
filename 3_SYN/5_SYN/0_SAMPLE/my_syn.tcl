set_db init_lib_search_path /home/hah006/Basic_SoC_implementation/ 
set_db init_lib_search_path /home/hah006/Basic_SoC_implementation/

read_libs /home/hah006/Basic_SoC_implementation/

read_hdl /home/hah006/Basic_SoC_implementation/

elaborate

read_sdc /home/hah006/Basic_SoC_implemantation/

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

write_hdl > ./outputs/GPIO_MUX_netlist.v
write_sdc > ./outputs/GPIO_MUX_final.sdc
