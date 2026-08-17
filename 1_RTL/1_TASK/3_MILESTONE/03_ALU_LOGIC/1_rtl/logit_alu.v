`timescale 1ns/1ps

module logit_alu (
	i_a	,
	i_b	,
	i_sel	,
	o_result
);

input		[7:0]	i_a	;
input		[7:0]	i_b	;
input		[2:0]	i_sel	;

output reg 	[7:0]	o_result;

wire		[7:0]	w_sum	;
wire		[7:0]	w_diff	;
wire		[7:0]	w_and	;
wire		[7:0]	w_or	;
wire		[7:0]	w_xor	;

wire	w_cout	;
wire	w_bout	;


sum_8_rca u_sum_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(1'b0	),
	.o_sum	(w_sum	),
	.o_cout (w_cout	)
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

xor_8 u_xor_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_xor	(w_xor	)
);


always @(*) begin

	case (i_sel)

		3'b000 : o_result = w_sum;
		3'b001 : o_result = w_diff;
		3'b010 : o_result = w_and;
		3'b011 : o_result = w_or;
		3'b100 : o_result = w_xor;
	
		default: o_result = 8'b0;
	
	endcase

end


endmodule
