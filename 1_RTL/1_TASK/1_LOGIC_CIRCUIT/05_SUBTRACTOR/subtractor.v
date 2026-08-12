`timescale 1ns/1ps

module subtractor(
	i_a	,
	i_b	,
	o_diff	,
	o_borrow
);

input	[31:0] 	i_a		;
input	[31:0] 	i_b		;

output 	[31:0] 	o_diff		;
output		o_borrow	;

wire 	[31:0]	w_b_inv		;
wire 		w_cout		;

// 2's complement
// A - B = A + (~B) + 1

assign w_b_inv = ~i_b;

// Ripple Carry Adder
ripple_carry_adder u_ripple_carry_adder (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(1'b1	),
	.o_sum	(o_diff	),
	.o_cout	(w_cout	)
);

// Carry out = 1 : No Borrow
// Carry out = 0 : Borrow
assign o_borrow = ~w_cout;

endmodule
