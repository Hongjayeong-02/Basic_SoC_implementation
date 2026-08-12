`timescale 1ns/1ps

module full_adder #(
	parameter WIDTH = 32
)(
	i_a	,
	i_b	, 
	i_cin	,
	o_sum	,
	o_cout
);

input 	[WIDTH-1:0] i_a	;
input 	[WIDTH-1:0] i_b	;
input 	[WIDTH-1:0] i_cin	;

output 	[WIDTH-1:0] o_sum	;
output 	[WIDTH-1:0] o_cout	;

wire 	[WIDTH-1:0] w_sum	;
wire	[WIDTH-1:0] w_carry0	;
wire 	[WIDTH-1:0] w_carry1	;

half_adder #(
	.WIDTH(WIDTH)
) u_half_adder_0 (
	.i_a	(i_a		),
	.i_b 	(i_b		),
	.o_sum	(w_sum		),
	.o_carry(w_carry0	)
);

half_adder #(
	.WIDTH(WIDTH)
) u_half_adder_1 (
	.i_a 	(w_sum		),
	.i_b	(i_cin		),
	.o_sum	(o_sum		),
	.o_carry(w_carry1	)
);

assign o_cout = w_carry0 | w_carry1;

endmodule
