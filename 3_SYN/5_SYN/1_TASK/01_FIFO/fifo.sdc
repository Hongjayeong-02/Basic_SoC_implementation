create_clock -name clk -period 10 -waveform {0 5} [get_ports i_clk]

set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]

set_clock_uncertainty 0.01 [get_clocks clk]

set_input_delay -max 1.0 -clock [get_clocks clk] [get_ports i_rst_n]
set_input_delay -max 1.0 -clock [get_clocks clk] [get_ports i_wr_en]
set_input_delay -max 1.0 -clock [get_clocks clk] [get_ports i_rd_en]
set_input_delay -max 1.0 -clock [get_clocks clk] [get_ports i_din]

set_output_delay -max 1.0 -clock [get_clocks clk] [get_ports o_dout]
set_output_delay -max 1.0 -clock [get_clocks clk] [get_ports o_full]
set_output_delay -max 1.0 -clock [get_clocks clk] [get_ports o_empty]
