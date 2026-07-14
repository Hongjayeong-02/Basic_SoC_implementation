# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Thu Jul 09 05:42:28 KST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design alu

set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
