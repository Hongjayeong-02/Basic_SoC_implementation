# Cadence Genus(TM) Synthesis Solution, Version 22.16-s078_1, built Jun 10 2024 14:32:57

# Date: Thu Aug 22 14:34:50 2024
# Host: npit.ic.rnd1 (x86_64 w/Linux 3.10.0-1160.el7.x86_64) (20cores*80cpus*2physical cpus*Intel(R) Xeon(R) Silver 4316 CPU @ 2.30GHz 30720KB)
# OS:   Red Hat Enterprise Linux Server release 7.9 (Maipo)
gui_raise
set_db init_lib_search_path ../../1_LIB
set_db init_hdl_search_path ../../4_SAMPLE_RTL
read_libs slow_vdd1v0_basicCells.lib
read_hdl counter.v
elaborate
read_sdc ../../2_CONSTRAINTS/sample.sdc
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
syn_map
syn_opt
report_timing > reports/report_timing.rpt
report_power > reports/report_power.rpt
report_area > reports/report_area.rpt
report_qor > reports/report_qor.rpt
write_hdl > outputs/counter_netlist.v
write_sdc > outputs/counter_sdc.sdc
#gui_raise
#exit
