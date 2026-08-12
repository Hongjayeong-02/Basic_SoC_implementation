`timescale 1ns/1ps

module half_adder #(
	parameter WIDTH = 32
)(
	i_a	,
	i_b	,
	o_sum	,
	o_carry
);

input 	[WIDTH-1:0] i_a	;
input 	[WIDTH-1:0] i_b	;

output 	[WIDTH-1:0] o_sum	;
output 	[WIDTH-1:0] o_carry	;

assign o_sum 	= i_a ^ i_b	;
assign o_carry 	= i_a & i_b	;

endmodule
