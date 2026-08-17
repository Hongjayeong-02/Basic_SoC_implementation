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


// ADD / SUB
wire		[7:0]	w_sum	;
wire		[7:0]	w_diff	;

wire	w_cout;
wire 	w_bout;

// LOGIC
wire		[7:0]	w_and	;
wire		[7:0]	w_or	;
wire		[7:0]	w_xor	;

// MUL
wire		[15:0]	w_mul	;

// DIVU
wire		[7:0]	w_divu_q;
wire		[7:0]	w_divu_r;

// DIVS
wire signed	[7:0]	w_divs_q;
wire signed	[7:0]	w_divs_r;


// ADD
sum_8_rca u_sum_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(1'b0	),
	.o_sum	(w_sum	),
	.o_cout (w_cout	)
);

// SUB
sub_8_rca u_sub_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_bin	(1'b0	),
	.o_diff	(w_diff	),
	.o_bout	(w_bout	)
);

// AND
and_8 u_and_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_and	(w_and	)
);

// OR
or_8 u_or_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_or	(w_or	)
);	

// XOR
xor_8 u_xor_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_xor	(w_xor	)
);

// MUL
mul_8 u_mul_8 (
	.i_a	 (i_a	),
	.i_b	 (i_b	),
	.o_result(w_mul	)
);

// DIVU
divu_8 u_divu_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_quotient	(w_divu_q	),
	.o_remainder	(w_divu_r	)
);

// DIVS
divs_8 u_divs_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_quotient	(w_divs_q	),
	.o_remainder	(w_divs_r	)
);

always @(*) begin

	case (i_sel)

		3'b000 : o_result = w_sum	;
		3'b001 : o_result = w_diff	;
		3'b010 : o_result = w_and	;
		3'b011 : o_result = w_or	;
		3'b100 : o_result = w_xor	;
	
		3'b101: o_result = w_mul[7:0]	;
		3'b110: o_result = w_divu_q	;	
		3'b111: o_result = w_divs_q	;		

		default: o_result = 8'b0	;
	
	endcase

end


endmodule
