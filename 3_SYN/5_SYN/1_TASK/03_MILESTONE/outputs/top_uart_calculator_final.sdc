# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Tue Aug 25 00:12:05 KST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design top_uart_calculator

set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
