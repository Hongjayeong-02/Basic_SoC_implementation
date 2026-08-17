`timescale 1ns/1ps

module sum_8_rca (
	i_a	,
	i_b	,
	i_cin	,
	o_sum	,
	o_cout	
);

input	[7:0]	i_a	;
input 	[7:0] 	i_b	;
input		i_cin	;

output 	[7:0]	o_sum	;
output		o_cout	;

wire 	[7:0] 	p	;
wire	[7:0]	g	;
wire	[8:0] 	carry	;

assign p = i_a ^ i_b	;
assign g = i_a & i_b	;

assign carry[0] = i_cin	;

assign carry[1] = g[0] |
		 (p[0] & carry[0]);

assign carry[2] = g[1] |	
		 (p[1] & g[0]) |
		 (p[1] & p[0] & carry[0]);

assign carry[3] = g[2] |
		 (p[2] & g[1]) |
		 (p[2] & p[1] & g[0]) |
		 (p[2] & p[1] & p[0] & carry[0]);

assign carry[4] = g[3] |
		 (p[3] & g[2]) |
		 (p[3] & p[2] & g[1]) |
		 (p[3] & p[2] & p[1] & g[0]) |
		 (p[3] & p[2] & p[1] & p[0] & carry[0]);

assign carry[5] = g[4] |
		 (p[4] & g[3]) |
		 (p[4] & p[3] & g[2]) |
		 (p[4] & p[3] & p[2] & g[1]) |
		 (p[4] & p[3] & p[2] & p[1] & g[0]) |
		 (p[4] & p[3] & p[2] & p[1] & p[0] & carry[0]);

assign carry[6] = g[5] |
		 (p[5] & g[4]) |
		 (p[5] & p[4] & g[3]) |
		 (p[5] & p[4] & p[3] & g[2]) |
		 (p[5] & p[4] & p[3] & p[2] & g[1]) |
		 (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) |
		 (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & carry[0]);

assign carry[7] = g[6] |
		 (p[6] & g[5]) |
		 (p[6] & p[5] & g[4]) |
		 (p[6] & p[5] & p[4] & g[3]) |
		 (p[6] & p[5] & p[4] & p[3] & g[2]) |
		 (p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) |
		 (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) |
		 (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & carry[0]);

assign carry[8] = g[7] |
		 (p[7] & g[6]) |
		 (p[7] & p[6] & g[5]) |
		 (p[7] & p[6] & p[5] & g[4]) |
		 (p[7] & p[6] & p[5] & p[4] & g[3]) |
		 (p[7] & p[6] & p[5] & p[4] & p[3] & g[2]) |
		 (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) |
		 (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) |
		 (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & carry[0]);

assign o_sum  = p ^ carry[7:0];
assign o_cout = carry[8];


endmodule
