`timescale 1ns/1ps

module alu_8 (
	i_a	,
	i_b	,
	i_sel	,
	o_result
);

input	[7:0] i_a	;
input 	[7:0] i_b	;
input	[1:0] i_sel	;

output	[7:0] o_result	;

wire	[7:0] w_sum	;
wire	[7:0] w_diff	;
wire	[7:0] w_and	;
wire	[7:0] w_or	;

wire	      w_cout	;
wire          w_bout	;


sum_8_rca u_sum_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(1'b0	),
	.o_sum	(w_sum	),
	.o_cout	(w_cout	)
);

sub_8_rca u_sub_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_bin	(1'b0	),
	.o_diff	(w_diff	),
	.o_bout	(w_bout	)
);

and_8 u_and_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_and	(w_and	)
);

or_8 u_or_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_or	(w_or	)
);

mux_8_4to1 u_mux_8_4to1 (
	.i_a	(w_sum	),
	.i_b	(w_diff	),
	.i_c	(w_and	),
	.i_d	(w_or	),
	.i_sel	(i_sel	),
	.o_y	(o_result)
);


endmodule
